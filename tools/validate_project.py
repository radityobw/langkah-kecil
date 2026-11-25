"""Offline repository & Godot project integrity validator for Langkah Kecil."""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$")
RES_PATH_RE = re.compile(r'"(res://[^"]+)"')
UID_RE = re.compile(r"uid://[A-Za-z0-9]+")
REL_MD_LINK_RE = re.compile(r"\]\((?!https?://|#|mailto:)[^)]+\)")
REL_HTML_SRC_RE = re.compile(r'src="(?!https?://)[^"]+"')


def check_version_ssot(errors: list[str]) -> None:
    godot_path = REPO_ROOT / "project.godot"
    if not godot_path.is_file():
        errors.append("Missing project.godot")
        return

    godot_txt = godot_path.read_text(encoding="utf-8")
    m = re.search(r'^config/version="([^"]+)"', godot_txt, flags=re.M)
    if not m:
        errors.append('Missing config/version="X.Y.Z" in project.godot')
        return

    version = m.group(1).strip()
    if not SEMVER_RE.match(version):
        errors.append(f"config/version is not valid semver: {version!r}")
        return

    changelog_path = REPO_ROOT / "CHANGELOG.md"
    if not changelog_path.is_file():
        errors.append("Missing CHANGELOG.md")
    else:
        cl_txt = changelog_path.read_text(encoding="utf-8")
        if f"## [{version}] - " not in cl_txt:
            errors.append(f"CHANGELOG.md missing heading '## [{version}] - '")

    citation_path = REPO_ROOT / "CITATION.cff"
    if not citation_path.is_file():
        errors.append("Missing CITATION.cff")
    else:
        cit_txt = citation_path.read_text(encoding="utf-8")
        if f'version: "{version}"' not in cit_txt:
            errors.append(f'CITATION.cff missing version: "{version}"')


def check_res_references(errors: list[str]) -> None:
    targets: list[Path] = [REPO_ROOT / "project.godot"]
    for pattern in ("*.gd", "*.tscn", "*.tres"):
        targets.extend(REPO_ROOT.rglob(pattern))

    for file_path in targets:
        if not file_path.is_file():
            continue
        rel_file = file_path.relative_to(REPO_ROOT).as_posix()
        if rel_file.startswith(".godot/"):
            continue
        text = file_path.read_text(encoding="utf-8", errors="replace")
        if file_path.suffix == ".gd":
            text = "\n".join(
                line for line in text.splitlines() if not line.lstrip().startswith("#")
            )
        for match in RES_PATH_RE.finditer(text):
            raw_res = match.group(1)
            if raw_res.startswith("res://.godot/"):
                continue
            rel_res = re.sub(r"/+", "/", raw_res[len("res://"):]).lstrip("/")
            if not rel_res:
                continue
            resolved = REPO_ROOT / rel_res
            if not resolved.exists():
                errors.append(f"Broken res:// reference in {rel_file}: {raw_res}")


def check_project_uids(errors: list[str]) -> None:
    godot_txt = (REPO_ROOT / "project.godot").read_text(encoding="utf-8")
    project_uids = set(UID_RE.findall(godot_txt))
    if not project_uids:
        return

    found_uids: set[str] = set()
    uid_assign_re = re.compile(r'uid="(uid://[A-Za-z0-9]+)"')
    for pattern in ("*.import", "*.tscn", "*.tres"):
        for path in REPO_ROOT.rglob(pattern):
            txt = path.read_text(encoding="utf-8", errors="replace")
            found_uids.update(uid_assign_re.findall(txt))

    for uid_file in REPO_ROOT.rglob("*.uid"):
        txt = uid_file.read_text(encoding="utf-8", errors="replace").strip()
        found_uids.update(UID_RE.findall(txt))

    for uid in sorted(project_uids):
        if uid not in found_uids:
            errors.append(f"Unresolved UID in project.godot: {uid}")


def check_export_presets(errors: list[str]) -> None:
    cfg_path = REPO_ROOT / "export_presets.cfg"
    if not cfg_path.is_file():
        errors.append("Missing export_presets.cfg")
        return

    lines = cfg_path.read_text(encoding="utf-8").splitlines()
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if stripped.startswith("export_path="):
            val = stripped.split("=", 1)[1].strip().strip('"')
            if (
                val.startswith("/")
                or val.startswith("\\")
                or re.match(r"^[A-Za-z]:", val)
                or "../" in val
                or "..\\" in val
            ):
                errors.append(f"export_presets.cfg:{idx} non-portable export_path: {val!r}")
        elif re.match(r"^keystore/.*password=", stripped):
            val = stripped.split("=", 1)[1].strip()
            if val not in ('""', "''", ""):
                errors.append(f"export_presets.cfg:{idx} non-empty keystore password")
        elif stripped.startswith("version/code="):
            val = stripped.split("=", 1)[1].strip()
            if not re.match(r"^\d+$", val):
                errors.append(f"export_presets.cfg:{idx} version/code is not an integer: {val!r}")


def check_governance_docs(errors: list[str]) -> None:
    doc_names = ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "SECURITY.md", "CREDITS.md", "LICENSE"]
    for name in doc_names:
        path = REPO_ROOT / name
        if not path.is_file():
            errors.append(f"Missing governance document: {name}")
            continue
        content = path.read_text(encoding="utf-8")
        if "\u2014" in content:
            errors.append(f"Em dash (U+2014) found in {name}")

    readme_path = REPO_ROOT / "README.md"
    if readme_path.is_file():
        readme = readme_path.read_text(encoding="utf-8")
        for m in REL_MD_LINK_RE.finditer(readme):
            errors.append(f"Relative Markdown link in README.md: {m.group(0)}")
        for m in REL_HTML_SRC_RE.finditer(readme):
            errors.append(f"Relative HTML src in README.md: {m.group(0)}")


def main() -> int:
    errors: list[str] = []
    check_version_ssot(errors)
    check_res_references(errors)
    check_project_uids(errors)
    check_export_presets(errors)
    check_governance_docs(errors)

    if errors:
        print(f"VALIDATION FAILED ({len(errors)} issue(s)):", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print("VALIDATION OK: version SSOT, res:// paths, UIDs, export_presets.cfg, and governance docs passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
