# Changelog

Seluruh perubahan penting pada proyek **Langkah Kecil** didokumentasikan pada berkas ini.

## [1.1.0] - 2026-11-25

### Ditambahkan & Ditingkatkan (Tata Kelola Repositori, Validasi Otomatis, CI/CD, & *GitHub Pages*)
- **SSOT Versi & Konfigurasi Ekspor ([`project.godot`](project.godot), [`export_presets.cfg`](export_presets.cfg)):** Menetapkan `config/version="1.1.0"` sebagai *Single Source of Truth* versi aplikasi, memindahkan `export_path` Android ke `build/android/langkah-kecil.apk` (`version/code=3`), serta menambahkan *preset* ekspor **Windows Desktop** dan **Linux** dengan pengecualian `tests/*`.
- **Perbaikan Referensi & Pembersihan Skrip ([`scene/tools/dreamcore.tscn`](scene/tools/dreamcore.tscn), [`script/`](script/)):** Memperbaiki referensi video yang hilang (`testdc.ogv`) pada `dreamcore.tscn` ke `res://assets/video/dreamcore1080.ogv` (`uid://dy8w66oxisecx`), serta membersihkan kode mati berkomentar pada `InventoryManager.gd`, `dragndrop.gd`, dan `level_button.gd` tanpa mengubah perilaku runtime.
- **Validasi Proyek & *Smoke Test Headless* ([`tools/validate_project.py`](tools/validate_project.py), [`tests/smoke_test.gd`](tests/smoke_test.gd)):** Menambahkan validator luring untuk SSOT versi, referensi `res://`, UID, `export_presets.cfg`, dan aturan dokumen, serta *smoke test headless* Godot 4.5 untuk seluruh `.tscn` dan `.gd`.
- **Otomatisasi CI/CD, Rilis, & *GitHub Pages* ([`.github/workflows/`](.github/workflows/), [`docs/`](docs/)):** Menambahkan *pipeline* CI (`ci.yml` dengan validator, **SIDIK**, dan kontainer `barichello/godot-ci:4.5`), alur rilis multi-platform (`release.yml`), situs statis *GitHub Pages* (`pages.yml` + `docs/build_site.py`), serta `CONTRIBUTING.md`, `SECURITY.md`, `CITATION.cff`, `CREDITS.md`, dan `.agents/rules/`.

## [1.0.0] - 2025-11-10

### Rilis Awal (`finishing v1`)
- **Modul Pengenalan Emosi:** 6 skenario emosi interaktif (`senang`, `sedih`, `marah`, `takut`, `malu`, `terkejut`) dengan umpan balik audio/visual.
- **Modul Jadwal Harian Anak:** Pengelola rutinitas harian (`pagi`, `siangsore`, `malam`) berbasis *drag-and-drop* dan penyimpanan otomatis lokal.
- **Sistem Audio & Navigasi Menu:** Implementasi menu utama, pemilihan level, pengaturan musik latar (`Backsound`), dan efek suara (`SelectSfx`, `Correctsfx`, `Wrongsfx`).
