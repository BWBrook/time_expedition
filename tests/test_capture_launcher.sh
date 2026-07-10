#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
real_godot=$(command -v godot)
tmp_base=${TMPDIR:-/tmp}
tmp_base=${tmp_base%/}
test_root=$(mktemp -d "$tmp_base/time-expedition-capture-launcher.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

fake_godot="$test_root/godot"
argv_log="$test_root/godot-argv"
marker="$test_root/godot-ran"
expected_argv="$test_root/expected-argv"
rejection_log="$test_root/rejection-log"
direct_log="$test_root/direct-rejection-log"

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

direct_target="$root/direct-capture"
direct_output="$repository_link/direct-capture"
test ! -e "$direct_target"
set +e
"$real_godot" \
    --headless \
    --path "$root" \
    --script res://tools/capture_qa.gd \
    -- \
    --viewport=1280x720 \
    --output="$direct_output" \
    > "$direct_log" 2>&1
direct_status=$?
set -e
test "$direct_status" -ne 0
grep -Fq "QA output must resolve outside the repository: $direct_output" "$direct_log"
test ! -e "$direct_target"

printf '%s\n' \
    'CAPTURE LAUNCHER TEST PASSED: exact argv; launcher symlink rejected before fake Godot; direct harness symlink rejected before write'
