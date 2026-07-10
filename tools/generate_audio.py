#!/usr/bin/env python3
from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44_100
OUTPUT = Path(__file__).resolve().parents[1] / "assets/audio/act_00"


def envelope(index: int, length: int, attack: float = 0.04, release: float = 0.18) -> float:
    attack_samples = max(1, int(length * attack))
    release_samples = max(1, int(length * release))
    rise = min(1.0, index / attack_samples)
    fall = min(1.0, (length - 1 - index) / release_samples)
    return max(0.0, min(rise, fall))


def sine(frequency: float, duration: float, amplitude: float = 0.4) -> list[float]:
    length = int(RATE * duration)
    return [
        amplitude * envelope(i, length) * math.sin(2.0 * math.pi * frequency * i / RATE)
        for i in range(length)
    ]


def chirp(start: float, end: float, duration: float, amplitude: float = 0.4) -> list[float]:
    length = int(RATE * duration)
    result: list[float] = []
    phase = 0.0
    for i in range(length):
        progress = i / max(1, length - 1)
        frequency = start + (end - start) * progress
        phase += 2.0 * math.pi * frequency / RATE
        result.append(amplitude * envelope(i, length, 0.06, 0.22) * math.sin(phase))
    return result


def noise(duration: float, amplitude: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    length = int(RATE * duration)
    return [
        rng.uniform(-amplitude, amplitude) * envelope(i, length, 0.02, 0.25)
        for i in range(length)
    ]


def mix(*tracks: list[float]) -> list[float]:
    length = max(len(track) for track in tracks)
    result = [0.0] * length
    for track in tracks:
        for i, value in enumerate(track):
            result[i] += value
    peak = max(1.0, max(abs(value) for value in result) / 0.92)
    return [value / peak for value in result]


def ambient() -> list[float]:
    rng = random.Random(1895)
    length = RATE * 8
    result: list[float] = []
    smooth = 0.0
    for i in range(length):
        smooth = smooth * 0.992 + rng.uniform(-1.0, 1.0) * 0.008
        value = smooth * 0.16
        tick_phase = i % RATE
        if tick_phase < 850:
            value += 0.18 * math.exp(-tick_phase / 150.0) * math.sin(
                2.0 * math.pi * 1_450.0 * tick_phase / RATE
            )
        result.append(value)
    return result


def bell() -> list[float]:
    duration = 1.8
    length = int(RATE * duration)
    frequencies = (392.0, 784.0, 1_176.0, 1_568.0)
    result: list[float] = []
    for i in range(length):
        time = i / RATE
        decay = math.exp(-2.4 * time)
        value = sum(
            math.sin(2.0 * math.pi * frequency * time) / (index + 1)
            for index, frequency in enumerate(frequencies)
        )
        result.append(0.36 * decay * value)
    return result


def write_wav(name: str, samples: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    path = OUTPUT / name
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, value)) * 32_767))
            for value in samples
        )
        handle.writeframes(frames)
    print(path.relative_to(OUTPUT.parents[2]))


def main() -> None:
    write_wav("ambient_workshop.wav", ambient())
    write_wav("paper.wav", mix(noise(0.34, 0.34, 12), sine(180.0, 0.34, 0.06)))
    write_wav("ivory_click.wav", mix(sine(820.0, 0.12, 0.34), noise(0.12, 0.08, 4)))
    write_wav("glass_chime.wav", mix(sine(1_180.0, 0.48, 0.34), sine(1_765.0, 0.48, 0.18)))
    write_wav("metal_click.wav", mix(sine(410.0, 0.17, 0.32), noise(0.17, 0.14, 8)))
    write_wav("misfire.wav", mix(chirp(240.0, 72.0, 0.9, 0.42), noise(0.9, 0.13, 31)))
    write_wav("departure.wav", mix(chirp(110.0, 2_200.0, 1.8, 0.44), sine(55.0, 1.8, 0.18)))
    write_wav("return.wav", mix(chirp(2_000.0, 180.0, 1.2, 0.4), sine(660.0, 1.2, 0.16)))
    write_wav("door_bell.wav", bell())


if __name__ == "__main__":
    main()
