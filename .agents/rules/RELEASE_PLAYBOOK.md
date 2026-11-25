# Panduan Rilis, Pembaruan, dan *Push* Repositori Langkah Kecil

Dokumen ini menjadi pedoman wajib bagi pengembang dan *AI agent* setiap kali memperbarui proyek, menaikkan versi (*version bump*), atau menerbitkan rilis di repositori **Langkah Kecil**.

---

## 1. Tata Kelola *Branch* (`main`)

* Pengembangan dilakukan pada *branch* **`main`** (atau melalui *Pull Request* dari *branch* fitur ke `main`).
* Setiap *push* dan *Pull Request* ke `main` memicu `.github/workflows/ci.yml` (*validator* Python, pemindaian keamanan **SIDIK**, serta *headless import* dan *smoke test* pada kontainer `barichello/godot-ci:4.5`).
* *Push* ke `main` yang menyentuh `docs/**`, `CHANGELOG.md`, atau `project.godot` memicu pembaruan otomatis situs *GitHub Pages* (`.github/workflows/pages.yml`).

---

## 2. Berkas Wajib Saat *Version Bump* (*Single Source of Truth*)

Ketika menaikkan versi ke `X.Y.Z`, perbarui **4 berkas** berikut:

1. **`project.godot`**: perbarui `config/version="X.Y.Z"` di bagian `[application]`.
2. **`export_presets.cfg`**: naikkan `version/code=<integer>` pada *preset* Android (`version/name=""` otomatis mengikuti `config/version`).
3. **`CHANGELOG.md`**: tambahkan bagian `## [X.Y.Z] - YYYY-MM-DD` di paling atas.
4. **`CITATION.cff`**: perbarui `version: "X.Y.Z"` dan `date-released: "YYYY-MM-DD"`.

---

## 3. Gerbang Verifikasi Wajib Sebelum *Push* (*Pre-Flight Gate*)

```powershell
python tools/validate_project.py
python docs/build_site.py --out _site
sidik --target . --mode all --fail-on high --quiet
```

Apabila Godot 4.5 terpasang secara lokal, jalankan pula:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/smoke_test.gd
```

Pastikan pula:
* Nol karakter *em dash* (`\u2014`) di berkas tata kelola (`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CREDITS.md`, `LICENSE`).
* Seluruh tautan dan gambar di `README.md` memakai URL absolut (`https://...`).
* Tidak ada berkas build (`.apk`, `.aab`, `.keystore`, `.jks`, `build/`, `.godot/`, `_site/`) dalam `git status`.

---

## 4. Prosedur Rilis Multi-Platform & *Container Package* (`release.yml`)

1. Pastikan CI pada `main` hijau.
2. Buat *tag* beranotasi `vX.Y.Z` lalu *push*:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z: <ringkasan>"
   git push origin vX.Y.Z
   ```
3. *Push tag* `v*` (atau publikasi *GitHub Release*) otomatis memicu `.github/workflows/release.yml`, yang mengekspor **Android Debug APK**, **Windows Desktop**, **Linux**, dan **Web Edition**, membuat *GitHub Release* (apabila belum ada), mengunggah keempat arsip `.zip` beserta `SHA256SUMS.txt`, serta membangun dan mendorong *container image* edisi Web ke `ghcr.io/radityobw/langkah-kecil:latest` dan `:X.Y.Z`.
