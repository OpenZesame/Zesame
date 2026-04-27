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

# Region-style markers for genuinely unreachable code that isn't a trap call (e.g. defensive
# branches kept for forward-compatibility). Place `// coverage:exclude-start` and
# `// coverage:exclude-end` on lines flanking the block to skip from the metric.
EXCLUDE_START_MARKER = re.compile(r"//\s*coverage:exclude-start\b")
EXCLUDE_END_MARKER = re.compile(r"//\s*coverage:exclude-end\b")


def trap_line_numbers(filepath: str) -> set:
    """Return 1-indexed line numbers covering trap calls, including continuation lines of
    multi-line invocations. Honours `// coverage:exclude-start` / `// coverage:exclude-end`
    region markers.

    Does NOT include surrounding control-flow lines (`else {`, closing `}`) — those are
    structurally reachable on the success path and confuse line-coverage accounting."""
    if not os.path.exists(filepath):
        return set()
    with open(filepath) as fh:
        lines = fh.readlines()

    traps: set[int] = set()

    in_region = False
    for idx, line in enumerate(lines):
        if EXCLUDE_START_MARKER.search(line):
            in_region = True
            traps.add(idx + 1)
            continue
        if EXCLUDE_END_MARKER.search(line):
            in_region = False
            traps.add(idx + 1)
            continue
        if in_region:
            traps.add(idx + 1)

    i = 0
    while i < len(lines):
        match = TRAP_PATTERNS.match(lines[i])
        if not match:
            i += 1
            continue
        indent = match.group(1)
        traps.add(i + 1)
        # llvm-cov places the region-entry segment for `else { TRAP }` on the line where the
        # `else {` opens, not on the trap call itself. The line's only segment has count 0 on
        # the success path, so it shows as uncovered even though the `else` keyword itself is
        # reached. Treat the opening line as part of the trap region.
        if i > 0:
            prev_stripped = lines[i - 1].rstrip()
            if prev_stripped.endswith("else {") or prev_stripped.endswith("} else {"):
                traps.add(i)
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
        # Trailing `}` lines that follow the trap with no intervening executable code are part
        # of the unreachable region.
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

    Subtracts the full trap set from `count`, and the subset that llvm-cov reports as covered
    from `covered`. Floors `new_count` at `new_covered` so we never report > 100%.
    """
    s = file_entry["summary"]["lines"]
    count, covered = s["count"], s["covered"]
    traps = trap_line_numbers(file_entry["filename"])
    if not traps:
        return count, covered

    line_counts: dict[int, int] = {}
    for seg in file_entry.get("segments", []):
        line_counts[seg[0]] = line_counts.get(seg[0], 0) + seg[2]

    excl_count = len(traps)
    excl_covered = sum(1 for ln in traps if line_counts.get(ln, 0) > 0)
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
