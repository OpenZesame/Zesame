#!/usr/bin/env python3
"""
Convert xcrun llvm-cov export JSON to xccov-compatible format for cov_table.py.
Usage: python3 llvm_to_xccov.py <llvm_cov.json> > coverage.json
"""
import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)
files_data = data["data"][0]["files"]

# Keep only Zesame source files (not dependencies, not generated files)
source_files = [f for f in files_data if "Sources/Zesame/" in f["filename"]]

files = []
total_lines = total_covered = 0

for f in source_files:
    s = f["summary"]["lines"]
    count, covered = s["count"], s["covered"]
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
