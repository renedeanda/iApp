#!/usr/bin/env python3
"""Inspect an App Store preview against Apple's core technical limits."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("video", type=Path)
    parser.add_argument("--expected-size", metavar="WIDTHxHEIGHT")
    return parser.parse_args()


def frame_rate(value: str) -> float:
    numerator, separator, denominator = value.partition("/")
    if not separator:
        return float(value)
    return float(numerator) / float(denominator)


def main() -> int:
    args = parse_args()
    if not args.video.is_file():
        print(f"FAIL: file not found: {args.video}")
        return 2
    if not shutil.which("ffprobe"):
        print("FAIL: ffprobe is required for deterministic stream inspection")
        return 2

    command = [
        "ffprobe", "-v", "error", "-show_streams", "-show_format",
        "-of", "json", str(args.video),
    ]
    probe = json.loads(subprocess.check_output(command, text=True))
    video_streams = [s for s in probe["streams"] if s.get("codec_type") == "video"]
    audio_streams = [s for s in probe["streams"] if s.get("codec_type") == "audio"]
    if len(video_streams) != 1:
        print(f"FAIL: expected one video stream, found {len(video_streams)}")
        return 1

    stream = video_streams[0]
    fmt = probe["format"]
    failures: list[str] = []
    warnings: list[str] = []

    duration = float(fmt.get("duration", 0))
    size = int(fmt.get("size", args.video.stat().st_size))
    fps = frame_rate(stream.get("avg_frame_rate", "0"))
    width, height = int(stream.get("width", 0)), int(stream.get("height", 0))
    codec = stream.get("codec_name", "unknown")
    field_order = stream.get("field_order", "unknown")
    bitrate = int(fmt.get("bit_rate", 0))

    if not 15 <= duration <= 30:
        failures.append(f"duration {duration:.2f}s is outside 15–30s")
    if size > 500_000_000:
        failures.append(f"file size {size / 1_000_000:.1f}MB exceeds 500MB")
    if args.video.suffix.lower() not in {".mov", ".m4v", ".mp4"}:
        failures.append(f"unsupported extension {args.video.suffix}")
    if codec not in {"h264", "prores"}:
        failures.append(f"unsupported video codec {codec}")
    if fps > 30.01:
        failures.append(f"frame rate {fps:.3f} exceeds 30fps")
    if field_order not in {"progressive", "unknown"}:
        failures.append(f"video is not progressive: {field_order}")

    if args.expected_size:
        expected_width, expected_height = map(int, args.expected_size.lower().split("x", 1))
        if (width, height) != (expected_width, expected_height):
            failures.append(
                f"resolution {width}x{height} does not match {expected_width}x{expected_height}"
            )

    if codec == "h264" and bitrate and not 10_000_000 <= bitrate <= 12_000_000:
        warnings.append(f"H.264 bitrate {bitrate / 1_000_000:.2f}Mbps is outside 10–12Mbps target")

    for audio in audio_streams:
        sample_rate = int(audio.get("sample_rate", 0))
        channels = int(audio.get("channels", 0))
        if audio.get("codec_name") not in {"aac", "pcm_s16le", "pcm_s24le", "pcm_s32le"}:
            failures.append(f"unsupported audio codec {audio.get('codec_name')}")
        if sample_rate not in {44_100, 48_000}:
            failures.append(f"unsupported audio sample rate {sample_rate}Hz")
        if channels != 2:
            failures.append(f"audio must be stereo; found {channels} channels")

    print(
        f"Video: {duration:.2f}s, {width}x{height}, {fps:.3f}fps, "
        f"{codec}, {size / 1_000_000:.1f}MB"
    )
    for warning in warnings:
        print(f"WARN: {warning}")
    for failure in failures:
        print(f"FAIL: {failure}")
    if failures:
        return 1
    print("PASS: core App Store preview technical checks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
