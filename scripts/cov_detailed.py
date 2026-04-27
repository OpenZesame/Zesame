#!/usr/bin/env python3
"""
Show per-source-file line coverage.
Fully-covered files → single green summary line.
Partially-covered files → only the uncovered lines, plus up to 3 lines of context
on either side (collapsed into ranges when adjacent uncovered lines overlap).

Usage: python3 cov_detailed.py <test_binary> <default.profdata> <coverage.json>
"""
import json, os, re, subprocess, sys

TEST_BIN  = sys.argv[1]
PROFDATA  = sys.argv[2]
COV_JSON  = sys.argv[3]
PACKAGE   = "Zesame"

RED    = "\033[31m"
GREEN  = "\033[32m"
YELLOW = "\033[33m"
DIM    = "\033[2m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

CONTEXT_LINES = 3

# Matches "   13|    0|" (uncovered) from llvm-cov show output
UNCOV_RE = re.compile(r"^\s*(\d+)\|\s*0\|")
COV_RE   = re.compile(r"^\s*(\d+)\|\s*(\d+)\|")


def fetch_counts(path: str) -> dict[int, int]:
    """Return {line_number: hit_count} for every executable line via llvm-cov show."""
    result = subprocess.run(
        [
            "xcrun", "llvm-cov", "show",
            TEST_BIN,
            f"-instr-profile={PROFDATA}",
            path,
        ],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return {}

    counts: dict[int, int] = {}
    for line in result.stdout.splitlines():
        m = COV_RE.match(line)
        if m:
            lineno, count = int(m.group(1)), int(m.group(2))
            counts[lineno] = count
    return counts


with open(COV_JSON) as fh:
    data = json.load(fh)

# For SPM packages there is no .app target; find the main source target by name.
target = next((t for t in data["targets"] if t["name"] == PACKAGE), None)
if target is None:
    target = next(
        (t for t in data["targets"]
         if not t["name"].endswith("Tests") and t.get("files")),
        None,
    )
if target is None:
    sys.exit(f"No suitable target found in coverage JSON (looked for '{PACKAGE}')")

files = sorted(target["files"], key=lambda f: os.path.basename(f["path"]))

for f in files:
    path = f["path"]
    name = os.path.basename(path)
    pct  = f["lineCoverage"]

    if pct == 1.0:
        print(f"{GREEN}✓ {name:<55} 100.0%{RESET}")
        continue

    counts = fetch_counts(path)
    if not counts:
        print(f"{DIM}? {name:<55}   n/a{RESET}")
        continue

    try:
        source_lines = open(path).readlines()
    except OSError:
        print(f"{DIM}? {name} — source not readable{RESET}")
        continue

    pct_str = f"{pct * 100:.1f}%"
    bar_color = YELLOW if pct >= 0.70 else RED
    print(f"\n{BOLD}{bar_color}▸ {name}{RESET}{bar_color}  {pct_str}{RESET}")
    print(f"{DIM}{'─' * 72}{RESET}")

    total_lines = len(source_lines)
    uncovered = sorted(ln for ln, c in counts.items() if c == 0)
    if not uncovered:
        # Coverage tooling and the JSON disagree (file <100% but no uncovered hits in show
        # output). Surface that rather than silently emitting nothing.
        print(f"{DIM}  (no uncovered lines reported by llvm-cov show){RESET}")
        continue

    # Collapse uncovered lines into windows of [first - CONTEXT, last + CONTEXT] and merge any
    # adjacent windows so consecutive blocks share their context instead of duplicating it.
    windows: list[tuple[int, int]] = []
    for ln in uncovered:
        start = max(1, ln - CONTEXT_LINES)
        end = min(total_lines, ln + CONTEXT_LINES)
        if windows and start <= windows[-1][1] + 1:
            windows[-1] = (windows[-1][0], max(windows[-1][1], end))
        else:
            windows.append((start, end))

    line_w = len(str(total_lines))
    for idx, (start, end) in enumerate(windows):
        if idx > 0:
            print(f"{DIM}  …{RESET}")
        for lineno in range(start, end + 1):
            source = source_lines[lineno - 1].rstrip("\n")
            count = counts.get(lineno)
            if count == 0:
                print(f"{RED}{lineno:{line_w}d}  ✗    {source}{RESET}")
            elif count is not None:
                print(f"{DIM}{lineno:{line_w}d}  {count:>4}  {source}{RESET}")
            else:
                print(f" {lineno:{line_w}d}        {source}")
