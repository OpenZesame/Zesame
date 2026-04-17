# Zesame — task runner (https://github.com/casey/just)
#
# Prerequisites:
#   brew install just swiftformat swiftlint xcpretty

set shell := ["zsh", "-cu"]

package    := "Zesame"
result_dir := ".build"
result     := result_dir + "/TestResults.xcresult"
cov_json   := result_dir + "/coverage.json"
profdata   := ".build/debug/codecov/default.profdata"
test_bin   := ".build/debug/ZesamePackageTests.xctest/Contents/MacOS/ZesamePackageTests"

# ── Default ───────────────────────────────────────────────────────────────────

# List available recipes
default:
    @just --list

# ── Building ──────────────────────────────────────────────────────────────────

# Build the package
build:
    swift build

# ── Testing ───────────────────────────────────────────────────────────────────

# Build and run the test suite
test:
    swift test

# Run tests, then print a pretty per-file coverage table.
# Produces .build/coverage.json for machine use (no extra tools required).
cov: _run-cov
    @python3 scripts/cov_table.py {{cov_json}}

# Like cov, but also shows every uncovered line highlighted red.
cov-detailed: _run-cov
    @python3 scripts/cov_detailed.py {{test_bin}} {{profdata}} {{cov_json}}

# ── Formatting ────────────────────────────────────────────────────────────────

# Auto-format all Swift sources in-place; silently skips any tool not installed.
fmt:
    @if command -v swiftformat >/dev/null 2>&1; then swiftformat Sources Tests; fi
    @if command -v swiftlint  >/dev/null 2>&1; then swiftlint --fix --force-exclude; fi

# ── Internal ──────────────────────────────────────────────────────────────────

# Run swift test with coverage and export llvm-cov JSON.
_run-cov:
    mkdir -p {{result_dir}}
    swift test --enable-code-coverage
    xcrun llvm-cov export \
        {{test_bin}} \
        -instr-profile {{profdata}} \
        -ignore-filename-regex "(Tests|checkouts|debug/|release/)" \
        > {{result_dir}}/llvm_cov.json
    @python3 scripts/llvm_to_xccov.py {{result_dir}}/llvm_cov.json > {{cov_json}}
