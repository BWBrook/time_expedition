#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

python_bin=${PYTHON:-python3}
key_helper="$root/tools/remove_chroma_key.py"
requirements_file="$root/requirements-art.txt"
source_dir="assets/art/act_00/source"
output_dir="assets/art/act_00"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/time-expedition-art.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT

require_file() {
    if [[ ! -f $1 ]]; then
        printf 'Missing required source: %s\n' "$1" >&2
        exit 1
    fi
}

require_pillow() {
    if ! "$python_bin" -c 'import PIL' >/dev/null 2>&1; then
        printf 'Pillow 12.2.0 is required by tools/remove_chroma_key.py. Install it with: %s -m pip install -r %s\n' "$python_bin" "$requirements_file" >&2
        exit 1
    fi
}

key_crop() {
    local input=$1
    local output=$2
    "$python_bin" "$key_helper" \
        --input "$input" \
        --out "$output" \
        --auto-key border \
        --soft-matte \
        --transparent-threshold 12 \
        --opaque-threshold 220 \
        --despill
}

clear_neighbor_fragment() {
    local path=$1
    local cutoff=$2
    magick "$path" \
        \( +clone -alpha extract -fill black -draw "rectangle ${cutoff},0 255,255" \) \
        -alpha off -compose CopyOpacity -composite -strip -define png:exclude-chunk=time "$path"
}

clear_alpha_region() {
    local path=$1
    local region=$2
    magick "$path" \
        \( +clone -alpha extract -fill black -draw "rectangle ${region}" \) \
        -alpha off -compose CopyOpacity -composite -strip -define png:exclude-chunk=time "$path"
}

write_checksum_block() {
    local provenance="$output_dir/ASSET_PROVENANCE.md"
    local block="$temp_dir/checksums.md"
    local rewritten="$temp_dir/provenance.md"
    if [[ ! -f $provenance ]]; then
        return
    fi

    {
        printf '%s\n' '<!-- BEGIN GENERATED CHECKSUMS: tools/process_art.sh -->'
        printf '%s\n\n' '## SHA-256 Checksums'
        printf '%s\n' '### Source plates'
        shasum -a 256 "$source_dir"/*.png
        printf '%s\n\n' '### Runtime assets'
        shasum -a 256 "$output_dir"/*.png
        printf '%s\n' '<!-- END GENERATED CHECKSUMS: tools/process_art.sh -->'
    } >"$block"

    awk -v block="$block" '
        /<!-- BEGIN GENERATED CHECKSUMS: tools\/process_art.sh -->/ {
            while ((getline line < block) > 0) print line
            close(block)
            skipping = 1
            next
        }
        /<!-- END GENERATED CHECKSUMS: tools\/process_art.sh -->/ && skipping {
            skipping = 0
            next
        }
        !skipping { print }
    ' "$provenance" >"$rewritten"
    mv "$rewritten" "$provenance"
}

for source in \
    workshop_master.png \
    time_traveller_master.png \
    workbench_master.png \
    model_frame_master.png \
    model_cloth_master.png \
    icon_strip_master.png; do
    require_file "$source_dir/$source"
done

require_file "$key_helper"
require_file "$requirements_file"
require_pillow
mkdir -p "$output_dir"

# The workshop must retain all eight approved horizontal anchors. The source is
# therefore resized to the authored runtime canvas rather than vertically cropped.
magick "$source_dir/workshop_master.png" -filter Lanczos -resize '3200x720!' -strip -define png:exclude-chunk=time "$output_dir/workshop_background.png"
magick "$source_dir/workbench_master.png" -filter Lanczos -resize '1280x720!' -strip -define png:exclude-chunk=time "$output_dir/workbench_background.png"

traveller_starts=(0 443 887 1330)
traveller_ends=(443 887 1330 1774)
for index in 0 1 2 3; do
    start=${traveller_starts[$index]}
    width=$((traveller_ends[$index] - start))
    crop="$temp_dir/traveller-$index-crop.png"
    keyed="$temp_dir/traveller-$index-keyed.png"
    normalized="$temp_dir/traveller-$index.png"
    magick "$source_dir/time_traveller_master.png" -crop "${width}x887+${start}+0" +repage "$crop"
    key_crop "$crop" "$keyed"
    magick "$keyed" -trim +repage -resize '430x440' -gravity south -background none -extent 512x488 -gravity north -extent 512x512 -strip -define png:exclude-chunk=time "$normalized"
done
magick \
    "$temp_dir/traveller-0.png" \
    "$temp_dir/traveller-1.png" \
    "$temp_dir/traveller-2.png" \
    "$temp_dir/traveller-3.png" \
    +append -strip -define png:exclude-chunk=time "$output_dir/time_traveller_strip.png"

key_crop "$source_dir/model_frame_master.png" "$temp_dir/model-frame-keyed.png"
magick "$temp_dir/model-frame-keyed.png" -trim +repage -resize '960x260' -gravity center -background none -extent 1024x300 -strip -define png:exclude-chunk=time "$output_dir/model_frame.png"

key_crop "$source_dir/model_cloth_master.png" "$temp_dir/model-cloth-keyed.png"
magick "$temp_dir/model-cloth-keyed.png" -trim +repage -resize '960x260' -gravity center -background none -extent 1024x300 -strip -define png:exclude-chunk=time "$output_dir/model_cloth.png"

icon_starts=(0 396 793 1189 1586)
icon_ends=(396 793 1189 1586 1983)
icon_names=(ivory_guides crystal_prism control_levers journal_icon inventory_icon)
for index in 0 1 2 3 4; do
    start=${icon_starts[$index]}
    width=$((icon_ends[$index] - start))
    crop="$temp_dir/icon-$index-crop.png"
    keyed="$temp_dir/icon-$index-keyed.png"
    magick "$source_dir/icon_strip_master.png" -crop "${width}x793+${start}+0" +repage "$crop"
    key_crop "$crop" "$keyed"
    magick "$keyed" -trim +repage -resize '200x200' -gravity center -background none -extent 256x256 -strip -define png:exclude-chunk=time "$output_dir/${icon_names[$index]}.png"
    case ${icon_names[$index]} in
        control_levers) clear_neighbor_fragment "$output_dir/${icon_names[$index]}.png" 205 ;;
        journal_icon)
            clear_neighbor_fragment "$output_dir/${icon_names[$index]}.png" 210
            clear_alpha_region "$output_dir/${icon_names[$index]}.png" '203,90 209,208'
            ;;
    esac
done

write_checksum_block
identify -format '%f %wx%h %[channels]\n' "$output_dir"/*.png
