#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/time-expedition-capture-launcher.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

fake_godot="$test_root/godot"
argv_log="$test_root/godot-argv"
marker="$test_root/godot-ran"
expected_argv="$test_root/expected-argv"
rejection_log="$test_root/rejection-log"

printf '%s\n' \
    '#!/bin/sh' \
    ': "${CAPTURE_QA_FAKE_LOG:?}"' \
    ': "${CAPTURE_QA_FAKE_MARKER:?}"' \
    'printf '\''%s\n'\'' "$@" > "$CAPTURE_QA_FAKE_LOG"' \
    'printf '\''ran\n'\'' > "$CAPTURE_QA_FAKE_MARKER"' \
    > "$fake_godot"
chmod +x "$fake_godot"

safe_output="$test_root/safe-output"
canonical_safe=$(python3 -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).resolve())' "$safe_output")
PATH="$test_root:$PATH" \
CAPTURE_QA_FAKE_LOG="$argv_log" \
CAPTURE_QA_FAKE_MARKER="$marker" \
    "$root/scripts/capture-qa.sh" --viewport=1440x900 --output="$safe_output"

printf '%s\n' \
    '--path' \
    '.' \
    '--resolution' \
    '1440x900' \
    '--script' \
    'res://tools/capture_qa.gd' \
    '--' \
    '--viewport=1440x900' \
    "--output=$canonical_safe" \
    > "$expected_argv"
cmp "$expected_argv" "$argv_log"
test -f "$marker"

rm -f "$argv_log" "$marker"
repository_link="$test_root/repository-link"
ln -s "$root" "$repository_link"
if PATH="$test_root:$PATH" \
    CAPTURE_QA_FAKE_LOG="$argv_log" \
    CAPTURE_QA_FAKE_MARKER="$marker" \
    "$root/scripts/capture-qa.sh" \
        --viewport=1440x900 \
        --output="$repository_link/capture-output" \
        > "$rejection_log" 2>&1; then
    printf '%s\n' 'Capture launcher accepted a symlink into the repository' >&2
    exit 1
fi
grep -q 'QA output must be outside the repository' "$rejection_log"
test ! -e "$marker"
test ! -e "$argv_log"

printf '%s\n' 'CAPTURE LAUNCHER TEST PASSED: exact argv; symlink rejected before Godot'
