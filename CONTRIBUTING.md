# Contributing to Langkah Kecil

Thank you for contributing to **Langkah Kecil**! This guide outlines project standards, local validation checks, and the release workflow.

---

## 1. Licensing & Attribution Mandate

All contributions are governed by the **Custom CC BY-NC 4.0 + Contributor Terms** license in [`LICENSE`](LICENSE) (personal and educational use only; commercial use prohibited without written permission).

* Document any new third-party visual, audio, or font assets in [`CREDITS.md`](CREDITS.md) with explicit source and license terms before committing.
* Do not commit child photos without verified permissions or any commercial-restricted assets incompatible with CC BY-NC 4.0.

---

## 2. Coding & Repository Standards

1. **Godot 4.5 & GDScript Formatting:** Use tabs for GDScript indentation (`.editorconfig`), keep `.gdignore` inside non-Godot folders (`docs/`, `tools/`), and never place `.gdignore` in `tests/`.
2. **No Em-Dashes (`\u2014`):** Use standard hyphens (`-`) or colons (`:`) in documentation, workflows, and license text.
3. **Absolute Links in `README.md`:** Use absolute `https://raw.githubusercontent.com/...` and `https://github.com/...` URLs in `README.md`.
4. **Build Artifacts Hygiene:** Never commit `.godot/`, `android/`, `build/`, `_site/`, `.apk`, `.aab`, `.keystore`, `.jks`, or `export_credentials.cfg`.

---

## 3. Pre-Flight Verification Gate

Run these checks locally before opening a Pull Request to `main`:

```bash
# 1. Run offline project validator (version SSOT, res:// paths, UIDs, presets, docs)
python tools/validate_project.py

# 2. Verify GitHub Pages static build
python docs/build_site.py --out _site

# 3. Run SIDIK security scan
sidik --target . --mode all --fail-on high --quiet

# 4. Run Godot 4.5 headless smoke test (if Godot 4.5 is installed locally)
godot --headless --path . --import
godot --headless --path . --script res://tests/smoke_test.gd
```

---

## 4. SSOT Release Checklist

When bumping the version (`X.Y.Z`):

1. Update `config/version="X.Y.Z"` in `project.godot`.
2. Increment `version/code` (integer) in `export_presets.cfg`.
3. Prepend `## [X.Y.Z] - YYYY-MM-DD` in `CHANGELOG.md`.
4. Update `version: "X.Y.Z"` and `date-released: "YYYY-MM-DD"` in `CITATION.cff`.
5. Run `python tools/validate_project.py` to confirm all SSOT files match before tagging `vX.Y.Z`.
