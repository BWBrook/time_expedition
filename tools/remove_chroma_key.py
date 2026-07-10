#!/usr/bin/env python3
"""Remove a border-sampled chroma key with a soft matte and despill."""

from __future__ import annotations

import argparse
from io import BytesIO
from pathlib import Path
from statistics import median
import sys


KEY_DOMINANCE_THRESHOLD = 16.0
ALPHA_NOISE_FLOOR = 8


def _load_image_module():
    try:
        from PIL import Image
    except ImportError as error:
        raise SystemExit(
            "Pillow 12.2.0 is required. Install the repo-pinned dependency with "
            "`python3 -m pip install -r requirements-art.txt`."
        ) from error
    return Image


def _clamp(value: float) -> int:
    return max(0, min(255, int(round(value))))


def _smoothstep(value: float) -> float:
    value = max(0.0, min(1.0, value))
    return value * value * (3.0 - 2.0 * value)


def _border_key(image) -> tuple[int, int, int]:
    width, height = image.size
    pixels = image.load()
    samples: list[tuple[int, int, int]] = []
    band = max(1, min(width, height, 6))
    step = max(1, min(width, height) // 256)
    for x in range(0, width, step):
        for y in range(band):
            samples.append(pixels[x, y][:3])
            samples.append(pixels[x, height - 1 - y][:3])
    for y in range(0, height, step):
        for x in range(band):
            samples.append(pixels[x, y][:3])
            samples.append(pixels[width - 1 - x, y][:3])
    return tuple(int(round(median(sample[channel] for sample in samples))) for channel in range(3))


def _spill_channels(key: tuple[int, int, int]) -> list[int]:
    key_max = max(key)
    if key_max < 128:
        return []
    return [index for index, value in enumerate(key) if value >= key_max - 16 and value >= 128]


def _key_dominance(rgb: tuple[int, int, int], key: tuple[int, int, int]) -> float:
    spill_channels = _spill_channels(key)
    if not spill_channels:
        return 0.0
    non_spill = [index for index in range(3) if index not in spill_channels]
    key_strength = min(rgb[index] for index in spill_channels)
    non_key_strength = max((rgb[index] for index in non_spill), default=0)
    return float(key_strength - non_key_strength)


def _alpha(rgb: tuple[int, int, int], key: tuple[int, int, int], transparent: float, opaque: float) -> int:
    distance = max(abs(rgb[index] - key[index]) for index in range(3))
    key_like = distance <= 32 or _key_dominance(rgb, key) >= KEY_DOMINANCE_THRESHOLD
    if not key_like:
        return 255
    distance_alpha = 0 if distance <= transparent else 255 if distance >= opaque else _clamp(
        255.0 * _smoothstep((distance - transparent) / (opaque - transparent))
    )
    spill_channels = _spill_channels(key)
    if not spill_channels:
        return distance_alpha
    non_spill = [index for index in range(3) if index not in spill_channels]
    key_strength = min(rgb[index] for index in spill_channels)
    non_key_strength = max((rgb[index] for index in non_spill), default=0)
    dominance = key_strength - non_key_strength
    dominance_alpha = 255 if dominance <= 0 else _clamp(
        255.0 * (1.0 - min(1.0, dominance / max(1.0, max(key) - non_key_strength)))
    )
    return min(distance_alpha, dominance_alpha)


def _despill(rgb: tuple[int, int, int], key: tuple[int, int, int], alpha: int) -> tuple[int, int, int]:
    if alpha >= 252:
        return rgb
    spill_channels = _spill_channels(key)
    if not spill_channels:
        return rgb
    channels = list(rgb)
    non_spill = [index for index in range(3) if index not in spill_channels]
    anchor = max((channels[index] for index in non_spill), default=0)
    for index in spill_channels:
        channels[index] = min(channels[index], max(0, anchor - 1))
    return tuple(channels)


def remove_chroma_key(input_path: Path, output_path: Path, transparent: float, opaque: float) -> None:
    Image = _load_image_module()
    with Image.open(input_path) as source:
        image = source.convert("RGBA")
    key = _border_key(image)
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, source_alpha = pixels[x, y]
            rgb = (red, green, blue)
            alpha = int(round(_alpha(rgb, key, transparent, opaque) * (source_alpha / 255.0)))
            if 0 < alpha <= ALPHA_NOISE_FLOOR:
                alpha = 0
            pixels[x, y] = (0, 0, 0, 0) if alpha == 0 else (*_despill(rgb, key, alpha), alpha)
    encoded = BytesIO()
    image.save(encoded, format="PNG")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(encoded.getvalue())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--auto-key", choices=["border"], required=True)
    parser.add_argument("--soft-matte", action="store_true", required=True)
    parser.add_argument("--transparent-threshold", type=float, required=True)
    parser.add_argument("--opaque-threshold", type=float, required=True)
    parser.add_argument("--despill", action="store_true", required=True)
    args = parser.parse_args()
    if args.transparent_threshold >= args.opaque_threshold:
        raise SystemExit("--transparent-threshold must be lower than --opaque-threshold.")
    remove_chroma_key(Path(args.input), Path(args.out), args.transparent_threshold, args.opaque_threshold)


if __name__ == "__main__":
    main()
