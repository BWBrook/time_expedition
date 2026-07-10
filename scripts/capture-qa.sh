#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

exec godot --path . --script res://tools/capture_qa.gd -- "$@"
