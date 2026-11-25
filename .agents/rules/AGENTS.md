# Pedoman Pengembangan dan Penulisan Repositori Langkah Kecil

Dokumen ini berisi aturan baku pengembangan, penulisan dokumentasi, serta pemeriksaan kualitas untuk seluruh agen di repositori **Langkah Kecil** (Godot Engine 4.5).

---

## 1. Aturan Tanda Baca: Bebas *Em Dash* (`\u2014`)

* **Tidak boleh ada *em dash* (`\u2014`)** di file tata kelola, dokumentasi Markdown, kode GDScript, skrip utilitas Python, maupun *workflow* GitHub Actions.
* Gunakan tanda strip standar (`-`), titik dua (`:`), atau format tanda baca yang sesuai sebagai pengganti.

---

## 2. Aturan Bahasa: Huruf Miring (*Italics*) untuk Istilah Asing

* Seluruh istilah, kata, atau frasa bahasa asing (khususnya Bahasa Inggris) yang digunakan di dalam narasi berbahasa Indonesia **wajib dicetak miring (*italics* / `*term*`)**, selaras dengan standar EYD V / PUEBI.
* Contoh: *game engine*, *drag-and-drop*, *autosave*, *feedback*, *headless*, *smoke test*, *pipeline*, *preset*, *freeware*.
* Singkatan huruf kapital (akronim seperti APK, SFX, UI, UX, UID, CI/CD, SAST, SCA) dan nama produk resmi (Godot Engine, GDScript, Android, Windows, Linux, SIDIK, GitHub Actions) tetap ditulis biasa tanpa huruf miring.

---

## 3. Konvensi Godot 4.5 & Pemeriksaan Wajib

* Pertahankan indentasi *tab* pada seluruh berkas `*.gd` (`.editorconfig`).
* Pastikan direktori non-Godot seperti `docs/` dan `tools/` memiliki berkas `.gdignore`, sedangkan `tests/` tidak memakai `.gdignore` agar `tests/smoke_test.gd` dapat dieksekusi oleh Godot.
* Jangan mengubah nama *signal* antar-`.tscn` dan skrip emosi (`malu.gd`, `marah.gd`, `sedih.gd`, `senang.gd`, `takut.gd`, `terkejut.gd`).
* Jalankan `python tools/validate_project.py` dan **SIDIK** setelah setiap perubahan sebelum melakukan *commit*.
