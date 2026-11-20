#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        printf 'Missing required command: %s\n' "$1" >&2
        exit 1
    }
}

run_bounded() {
    seconds=$1
    shift
    perl -e 'alarm shift @ARGV; exec @ARGV' "$seconds" "$@"
}

run_clean_bounded() {
    seconds=$1
    shift
    log=$(mktemp)
    status=0
    run_bounded "$seconds" "$@" >"$log" 2>&1 || status=$?
    cat "$log"
    if [ "$status" -ne 0 ]; then
        rm -f "$log"
        return "$status"
    fi
    if grep -Eq 'ObjectDB instances were leaked|resources still in use|SCRIPT ERROR' "$log"; then
        printf '%s\n' 'Headless boot emitted a shutdown or script diagnostic' >&2
        rm -f "$log"
        return 1
    fi
    rm -f "$log"
}

printf '%s\n' '==> Checking engine and dependencies'
require_command godot
require_command python3
require_command magick
require_command perl
require_command bash
for tool in sh git find sort cmp mktemp grep sed awk identify chmod ln rm; do
    require_command "$tool"
done

godot_version=$(godot --version)
case "$godot_version" in
    4.7.*) printf 'Godot %s\n' "$godot_version" ;;
    *) printf 'Expected Godot 4.7.x, got %s\n' "$godot_version" >&2; exit 1 ;;
esac
python3 - <<'PY'
import pathlib
import PIL

requirements = pathlib.Path("requirements-art.txt").read_text(encoding="utf-8")
assert "Pillow>=12.2,<13" in requirements
major, minor, *_ = (int(part) for part in PIL.__version__.split("."))
assert (major, minor) >= (12, 2) and major < 13, PIL.__version__
print(f"Python Pillow {PIL.__version__}")
PY
imagemagick_version=$(magick -version | awk 'NR == 1 { print $3 }')
case "$imagemagick_version" in
    7.1.2-*) ;;
    *)
    printf 'Expected ImageMagick 7.1.2.x, got %s\n' "$imagemagick_version" >&2
    exit 1
    ;;
esac
printf 'ImageMagick %s\n' "$imagemagick_version"

printf '%s\n' '==> Regenerating deterministic art'
tools/process_art.sh
printf '%s\n' '==> Regenerating deterministic audio'
python3 tools/generate_audio.py
printf '%s\n' '==> First Godot import'
run_bounded 60 godot --headless --path . --import
printf '%s\n' '==> Building deterministic content'
run_bounded 60 godot --headless --path . --script res://tools/build_content.gd
printf '%s\n' '==> Second Godot import'
run_bounded 60 godot --headless --path . --import
printf '%s\n' '==> Bounded main boot'
run_clean_bounded 20 godot --headless --path . --quit-after 1
printf '%s\n' '==> Bounded workshop boot'
run_clean_bounded 20 godot --headless --path . res://game/act_00/workshop.tscn --quit-after 1
printf '%s\n' '==> Capture launcher boundary regression'
run_bounded 20 tests/test_capture_launcher.sh
printf '%s\n' '==> Complete GDScript suite'
run_bounded 120 godot --headless --path . --script res://tests/run_all.gd
printf '%s\n' '==> Checking deterministic generated surfaces'
git diff --exit-code -- game/content/act_00/act_00_manifest.tres assets/audio/act_00/*.wav assets/art/act_00/*.png
untracked_generated=$(git ls-files --others --exclude-standard -- game/content/act_00 assets/audio/act_00/*.wav assets/art/act_00/*.png)
if [ -n "$untracked_generated" ]; then
    printf '%s\n%s\n' 'Untracked generated files are not allowed:' "$untracked_generated" >&2
    exit 1
fi
