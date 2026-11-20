#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

command -v godot >/dev/null 2>&1 || {
    printf '%s\n' 'Missing required command: godot' >&2
    exit 1
}

exec godot --headless --path . --script res://tests/run_all.gd -- --fast
