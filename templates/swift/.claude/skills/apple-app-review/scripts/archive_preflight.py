#!/usr/bin/env python3
"""Read-only structural preflight for an .xcarchive or built .app bundle."""

from __future__ import annotations

import argparse
import json
import plistlib
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


def read_plist(path: Path) -> dict[str, Any]:
    try:
        with path.open("rb") as handle:
            value = plistlib.load(handle)
        return value if isinstance(value, dict) else {}
    except (OSError, plistlib.InvalidFileException):
        return {}


def entitlements(bundle: Path) -> dict[str, Any]:
    proc = subprocess.run(
        ["/usr/bin/codesign", "-d", "--entitlements", "-", str(bundle)],
        capture_output=True,
        check=False,
    )
    raw = proc.stdout or proc.stderr
    start = raw.find(b"<?xml")
    if start < 0:
        start = raw.find(b"<plist")
    if start < 0:
        # Xcode 26's codesign renders DER entitlements as a bracketed tree.
        text = raw.decode("utf-8", errors="replace")
        parsed: dict[str, Any] = {}
        matches = list(re.finditer(r"\[Key\]\s+([^\r\n]+)", text))
        for index, match in enumerate(matches):
            key = match.group(1).strip()
            end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
            section = text[match.end():end]
            bool_match = re.search(r"\[Bool\]\s+(true|false)", section, re.IGNORECASE)
            string_match = re.search(r"\[String\]\s+([^\r\n]+)", section)
            parsed[key] = (
                bool_match.group(1).lower() == "true"
                if bool_match
                else string_match.group(1).strip() if string_match else "present"
            )
        return parsed
    try:
        value = plistlib.loads(raw[start:])
        return value if isinstance(value, dict) else {}
    except plistlib.InvalidFileException:
        return {}


def main_app(input_path: Path) -> tuple[Path | None, str]:
    if input_path.suffix == ".app" and input_path.is_dir():
        return input_path, "app"
    if input_path.suffix == ".xcarchive" and input_path.is_dir():
        apps = sorted((input_path / "Products" / "Applications").glob("*.app"))
        return (apps[0], "archive") if apps else (None, "archive")
    return None, "unknown"


def add(findings: list[dict[str, str]], severity: str, code: str, message: str) -> None:
    findings.append({"severity": severity, "code": code, "message": message})


def inspect(input_path: Path) -> dict[str, Any]:
    app, input_type = main_app(input_path)
    result: dict[str, Any] = {
        "input": str(input_path.resolve()),
        "input_type": input_type,
        "app": str(app) if app else None,
        "bundle_id": None,
        "version": None,
        "build": None,
        "targets": [],
        "findings": [],
    }
    findings: list[dict[str, str]] = result["findings"]
    if app is None:
        add(findings, "blocker", "artifact.invalid", "No main .app bundle was found.")
        return result

    info_path = app / "Info.plist"
    info = read_plist(info_path)
    if not info:
        add(findings, "blocker", "info.missing", f"Unreadable Info.plist: {info_path}")
        return result

    result["bundle_id"] = info.get("CFBundleIdentifier")
    result["version"] = info.get("CFBundleShortVersionString")
    result["build"] = info.get("CFBundleVersion")
    for key, code in (
        ("CFBundleIdentifier", "bundle.id.missing"),
        ("CFBundleShortVersionString", "version.missing"),
        ("CFBundleVersion", "build.missing"),
    ):
        if not info.get(key):
            add(findings, "blocker", code, f"{key} is missing from the built app.")

    bundles = [app] + sorted((app / "PlugIns").glob("*.appex")) + sorted(
        (app / "Watch").glob("*.app")
    )
    for bundle in bundles:
        bundle_info = read_plist(bundle / "Info.plist")
        manifests = sorted(str(p.relative_to(bundle)) for p in bundle.rglob("PrivacyInfo.xcprivacy"))
        ents = entitlements(bundle)
        target = {
            "path": str(bundle),
            "bundle_id": bundle_info.get("CFBundleIdentifier"),
            "type": bundle.suffix.lstrip("."),
            "privacy_manifests": manifests,
            "background_modes": bundle_info.get("UIBackgroundModes", []),
            "entitlement_keys": sorted(ents.keys()),
        }
        result["targets"].append(target)
        if ents.get("get-task-allow") is True:
            add(
                findings,
                "manual",
                "entitlement.debuggable",
                f"get-task-allow=true in archived {bundle.name}; Xcode may re-sign during distribution, so verify the exported/uploaded artifact has it disabled.",
            )
        if bundle != app and not manifests:
            add(
                findings,
                "manual",
                "extension.privacy-manifest",
                f"{bundle.name} has no embedded PrivacyInfo.xcprivacy; verify whether its APIs require one.",
            )

    modes = info.get("UIBackgroundModes", [])
    if isinstance(modes, list) and "audio" in modes:
        add(
            findings,
            "high",
            "background.audio",
            "The shipping app declares the audio background mode; verify continuous background audio is a core feature.",
        )
    ats = info.get("NSAppTransportSecurity", {})
    if isinstance(ats, dict) and ats.get("NSAllowsArbitraryLoads") is True:
        add(findings, "high", "ats.arbitrary-loads", "NSAllowsArbitraryLoads=true in the shipping app.")
    if "ITSAppUsesNonExemptEncryption" not in info:
        add(
            findings,
            "manual",
            "export.encryption",
            "ITSAppUsesNonExemptEncryption is not declared; answer export compliance accurately in App Store Connect.",
        )
    if not any((bundle / "PrivacyInfo.xcprivacy").exists() for bundle in bundles):
        add(
            findings,
            "manual",
            "privacy.manifest.none",
            "No top-level PrivacyInfo.xcprivacy was found; verify required-reason API and SDK obligations.",
        )
    if not findings:
        add(findings, "info", "structure.clean", "No structural risk signals detected by this preflight.")
    return result


def markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Archive preflight",
        "",
        f"- Input: `{result['input']}`",
        f"- Bundle ID: `{result.get('bundle_id') or 'unknown'}`",
        f"- Version/build: `{result.get('version') or '?'} ({result.get('build') or '?'})`",
        "",
        "## Targets",
        "",
    ]
    for target in result["targets"]:
        manifests = ", ".join(target["privacy_manifests"]) or "none"
        modes = ", ".join(target["background_modes"]) or "none"
        lines.append(f"- `{target['bundle_id'] or target['path']}` — privacy: {manifests}; background: {modes}")
    lines.extend(["", "## Findings", ""])
    for finding in result["findings"]:
        lines.append(f"- **{finding['severity'].upper()}** `{finding['code']}` — {finding['message']}")
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact", type=Path, help="Path to an .xcarchive or .app")
    parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    return parser.parse_args()


def run() -> int:
    args = parse_args()
    result = inspect(args.artifact)
    print(json.dumps(result, indent=2, sort_keys=True) if args.format == "json" else markdown(result), end="")
    return 2 if any(f["severity"] == "blocker" for f in result["findings"]) else 0


if __name__ == "__main__":
    sys.exit(run())
