#!/usr/bin/env bash
# Regenerates every `*.pb.swift` next to its `*.proto` source under Sources/.
#
# Requires the `swift-protobuf` toolchain:
#   brew install swift-protobuf
#
# This installs both `protoc` and the `protoc-gen-swift` plugin (the latter must be on PATH
# for `protoc --swift_out=...` to work).

set -euo pipefail

# Resolve repo root from this script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

require() {
    local cmd="$1" install="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "error: '$cmd' not found on PATH. Install with: $install" >&2
        exit 1
    fi
}

require protoc "brew install swift-protobuf"
require protoc-gen-swift "brew install swift-protobuf"

cd "$REPO_ROOT"

count=0
while IFS= read -r -d '' proto; do
    dir="$(dirname "$proto")"
    file="$(basename "$proto")"
    echo "regenerating: $proto"
    (
        cd "$dir"
        protoc \
            --swift_opt=Visibility=Public \
            --swift_out=. \
            "$file"
    )
    count=$((count + 1))
done < <(find Sources -type f -name '*.proto' -print0)

if [ "$count" -eq 0 ]; then
    echo "no .proto files found under Sources/"
else
    echo "done. regenerated $count file(s)."
fi
