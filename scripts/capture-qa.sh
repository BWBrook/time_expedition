#!/usr/bin/env bash
set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

viewport=''
output=''
for argument in "$@"; do
    case "$argument" in
        --viewport=*)
            [[ -z "$viewport" ]] || fail 'Duplicate --viewport argument'
            viewport=${argument#--viewport=}
            ;;
        --output=*)
            [[ -z "$output" ]] || fail 'Duplicate --output argument'
            output=${argument#--output=}
            ;;
        *)
            fail "Unknown argument: $argument"
            ;;
    esac
done

[[ -n "$viewport" && -n "$output" ]] || \
    fail 'Usage: scripts/capture-qa.sh --viewport=WIDTHxHEIGHT --output=/absolute/path/outside/repository'
[[ "$viewport" =~ ^([1-9][0-9]*)x([1-9][0-9]*)$ ]] || \
    fail 'Viewport must be WIDTHxHEIGHT using positive integers'
[[ "$output" = /* ]] || fail 'QA output must be an absolute path'

width=$((10#${BASH_REMATCH[1]}))
height=$((10#${BASH_REMATCH[2]}))
viewport="${width}x${height}"

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
root="$script_dir/.."
canonical_paths=()
while IFS= read -r path; do
    canonical_paths+=("$path")
done < <(python3 - "$root" "$output" <<'PY'
import pathlib
import sys

repository = pathlib.Path(sys.argv[1]).resolve()
output = pathlib.Path(sys.argv[2]).resolve()
if output == repository or repository in output.parents:
    raise SystemExit(f"QA output must be outside the repository: {output}")
print(repository)
print(output)
PY
)

[[ ${#canonical_paths[@]} -eq 2 ]] || fail 'Unable to canonicalize QA paths'
root=${canonical_paths[0]}
output=${canonical_paths[1]}
cd "$root"

exec godot --path . --resolution "$viewport" --script res://tools/capture_qa.gd -- \
    "--viewport=$viewport" "--output=$output"
