#!/usr/bin/env python3
"""
Convert xcrun llvm-cov export JSON to xccov-compatible format for cov_table.py.

Excludes trap-like defensive lines (`fatalError(...)`, `preconditionFailure(...)`,
`precondition(...)`) from the executable-line count: these are unreachable on the success path
and can't be covered without process-fork death tests, which Swift Testing doesn't support.

Multi-line trap calls (`fatalError(\n    "msg",\n    extra: foo\n)`) are detected by walking
forward from the start line until a line at or below the trap's indent that begins with `)` is
found.

Usage: python3 llvm_to_xccov.py <llvm_cov.json> > coverage.json
"""
import json
import os
import re
import sys

TRAP_PATTERNS = re.compile(r"^(\s*)(?:.*?\b)?(fatalError|preconditionFailure|precondition)\s*\(")


def trap_line_numbers(filepath: str) -> set:
    """Return 1-indexed line numbers covering trap calls, including continuation lines of
    multi-line invocations and trailing closing braces of the enclosing block when those braces
    can't be reached without first executing the trap."""
    if not os.path.exists(filepath):
        return set()
    with open(filepath) as fh:
        lines = fh.readlines()

    traps: set[int] = set()
    i = 0
    while i < len(lines):
        match = TRAP_PATTERNS.match(lines[i])
        if not match:
            i += 1
            continue
        indent = match.group(1)
        traps.add(i + 1)
        # If the immediately preceding line opens a control flow that exists only to enter this
        # trap (e.g. `} else {`, `guard ... else {`), mark that line too.
        if i > 0:
            prev_stripped = lines[i - 1].rstrip()
            if prev_stripped.endswith("else {") or prev_stripped.endswith("} else {"):
                traps.add(i)
        # If the call closes on the same line, we're done with the call itself.
        if lines[i].rstrip().endswith(")"):
            j = i
        else:
            # Walk forward marking continuation lines until a line beginning with `)` at the
            # same indent.
            j = i + 1
            while j < len(lines):
                stripped = lines[j].lstrip()
                traps.add(j + 1)
                if stripped.startswith(")") and lines[j].startswith(indent + ")"):
                    break
                j += 1

        # Now sweep trailing closing braces — `}` lines at outer indents — that follow the trap
        # without intervening executable code. Stop at the first non-`}` non-blank line.
        k = j + 1
        while k < len(lines):
            stripped = lines[k].strip()
            if stripped == "":
                k += 1
                continue
            if stripped == "}" or stripped.startswith("} "):
                traps.add(k + 1)
                k += 1
                continue
            break
        i = k
    return traps


def adjust_summary(file_entry):
    """Return (effective_count, effective_covered) after excluding trap lines.

    We approximate: every trap line we identify in the source is treated as one executable line
    that should not contribute to coverage. Some of those lines (string-literal continuations
    inside `fatalError(\\n  "msg"\\n)`) aren't counted as separate region entries by llvm-cov,
    but they ARE counted in `summary.lines.count` line-by-line, so subtracting the full trap
    set keeps the metric honest.
    """
    s = file_entry["summary"]["lines"]
    count, covered = s["count"], s["covered"]
    traps = trap_line_numbers(file_entry["filename"])
    if not traps:
        return count, covered

    # Lines llvm-cov saw at least one segment for that were executed.
    covered_lines = {seg[0] for seg in file_entry.get("segments", []) if seg[2] > 0}

    excl_count = len(traps)
    excl_covered = len(traps & covered_lines)
    new_count = max(count - excl_count, covered - excl_covered)
    new_covered = covered - excl_covered
    return new_count, new_covered


with open(sys.argv[1]) as f:
    data = json.load(f)
files_data = data["data"][0]["files"]

source_files = [f for f in files_data if "Sources/Zesame/" in f["filename"]]

files = []
total_lines = total_covered = 0

for f in source_files:
    count, covered = adjust_summary(f)
    pct = covered / count if count > 0 else 0.0
    total_lines += count
    total_covered += covered
    files.append({
        "path": f["filename"],
        "executableLines": count,
        "coveredLines": covered,
        "lineCoverage": pct,
    })

result = {
    "targets": [{
        "name": "Zesame",
        "executableLines": total_lines,
        "coveredLines": total_covered,
        "lineCoverage": total_covered / total_lines if total_lines > 0 else 0.0,
        "files": files,
    }]
}
print(json.dumps(result, indent=2))
