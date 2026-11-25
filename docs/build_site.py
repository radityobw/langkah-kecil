"""Auto-sync static GitHub Pages bundle from project.godot config/version and CHANGELOG.md."""

import argparse
import html
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

DOCS_DIR = Path(__file__).resolve().parent
REPO_ROOT = DOCS_DIR.parent


def _read_version() -> str:
    txt = (REPO_ROOT / "project.godot").read_text(encoding="utf-8")
    m = re.search(r'^config/version="([^"]+)"', txt, flags=re.M)
    if not m:
        raise RuntimeError('Could not parse config/version from project.godot')
    return m.group(1).strip()


def _read_lastmod() -> str:
    try:
        res = subprocess.run(
            ["git", "-C", str(REPO_ROOT), "log", "-1", "--format=%cs"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        out = res.stdout.strip()
        if res.returncode == 0 and re.match(r"^\d{4}-\d{2}-\d{2}$", out):
            return out
    except Exception:
        pass
    return datetime.now(timezone.utc).strftime("%Y-%m-%d")


def _md_inline_to_html(text: str) -> str:
    clean = text.replace("\u2014", "-")
    clean = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", clean)
    escaped = html.escape(clean, quote=True)
    escaped = re.sub(r"`([^`]+)`", r"<code>\1</code>", escaped)
    escaped = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", escaped)
    escaped = re.sub(r"\*([^*]+)\*", r"<em>\1</em>", escaped)
    return escaped


def _render_latest_releases(max_releases: int = 2) -> tuple[str, int]:
    cl_path = REPO_ROOT / "CHANGELOG.md"
    if not cl_path.is_file():
        return "<p>No changelog entries found.</p>", 0

    sections: list[tuple[str, str, list[str]]] = []
    cur_ver: Optional[str] = None
    cur_date: str = ""
    cur_bullets: list[str] = []

    for raw in cl_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        hm = re.match(r"^##\s+\[([^\]]+)\]\s*-\s*(\d{4}-\d{2}-\d{2})", line)
        if hm:
            if cur_ver is not None:
                sections.append((cur_ver, cur_date, cur_bullets))
                if len(sections) >= max_releases:
                    break
            cur_ver = hm.group(1)
            cur_date = hm.group(2)
            cur_bullets = []
            continue
        if cur_ver is not None and line.startswith("- ") and len(cur_bullets) < 4:
            cur_bullets.append(line[2:].strip())

    if cur_ver is not None and len(sections) < max_releases:
        sections.append((cur_ver, cur_date, cur_bullets))

    cards = []
    for ver, dt, bullets in sections:
        items_html = "\n".join(f"            <li>{_md_inline_to_html(b)}</li>" for b in bullets)
        cards.append(
            f'        <article class="release-card">\n'
            f'          <div class="release-head">\n'
            f'            <span class="release-tag">v{html.escape(ver)}</span>\n'
            f'            <span class="release-date">{html.escape(dt)}</span>\n'
            f'          </div>\n'
            f'          <ul>\n{items_html}\n          </ul>\n'
            f'        </article>'
        )
    return "\n".join(cards), len(sections)


def build_site(out_dir: Path) -> None:
    version = _read_version()
    lastmod = _read_lastmod()
    releases_html, n_rel = _render_latest_releases(max_releases=2)

    html_src = (DOCS_DIR / "index.html").read_text(encoding="utf-8")
    html_out = re.sub(
        r'(<span class="eyebrow">)v\d+\.\d+\.\d+',
        rf"\g<1>v{version}",
        html_src,
        count=1,
    )
    html_out = re.sub(
        r'("softwareVersion"\s*:\s*")[^"]+(")',
        rf'\g<1>{version}\g<2>',
        html_out,
        count=1,
    )
    html_out = re.sub(
        r"<!-- AUTO_CHANGELOG_START -->.*?<!-- AUTO_CHANGELOG_END -->",
        f"<!-- AUTO_CHANGELOG_START -->\n{releases_html}\n        <!-- AUTO_CHANGELOG_END -->",
        html_out,
        flags=re.S,
    )
    html_out = re.sub(
        r"<!-- AUTO_UPDATED_START -->.*?<!-- AUTO_UPDATED_END -->",
        f"<!-- AUTO_UPDATED_START -->Updated {lastmod}<!-- AUTO_UPDATED_END -->",
        html_out,
        flags=re.S,
    )

    sitemap_src = (DOCS_DIR / "sitemap.xml").read_text(encoding="utf-8")
    sitemap_out = re.sub(
        r"<lastmod>[^<]+</lastmod>",
        f"<lastmod>{lastmod}</lastmod>",
        sitemap_src,
        count=1,
    )

    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "index.html").write_text(html_out, encoding="utf-8")
    (out_dir / "sitemap.xml").write_text(sitemap_out, encoding="utf-8")

    for fname in (
        ".nojekyll",
        "robots.txt",
        "sitemap.txt",
        "og-banner.png",
        "favicon.ico",
        "favicon-48x48.png",
        "favicon-192x192.png",
        "apple-touch-icon.png",
    ):
        src = DOCS_DIR / fname
        if src.is_file():
            shutil.copy2(src, out_dir / fname)

    icon_src = REPO_ROOT / "assets" / "picture" / "lkk.jpeg"
    if icon_src.is_file():
        shutil.copy2(icon_src, out_dir / "logo.jpeg")

    print(f"Built Langkah Kecil Pages v{version} (lastmod={lastmod}, releases={n_rel}) -> {out_dir}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build auto-synced static GitHub Pages output for Langkah Kecil.")
    parser.add_argument("--out", default="_site", help="Output directory path (default: _site)")
    args = parser.parse_args()
    out_path = Path(args.out)
    if not out_path.is_absolute():
        out_path = REPO_ROOT / out_path
    build_site(out_path)


if __name__ == "__main__":
    main()
