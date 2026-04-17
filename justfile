# Zesame — task runner (https://github.com/casey/just)
#
# Prerequisites:
#   brew install just swiftformat swiftlint

set shell := ["zsh", "-cu"]

package := "Zesame"

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

# ── Formatting ────────────────────────────────────────────────────────────────

# Auto-format all Swift sources in-place; silently skips any tool not installed.
fmt:
    @if command -v swiftformat >/dev/null 2>&1; then swiftformat Sources Tests; fi
    @if command -v swiftlint  >/dev/null 2>&1; then swiftlint --fix --force-exclude; fi
