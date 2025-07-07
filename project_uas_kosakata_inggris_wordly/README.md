# 🌟 **Tugas Besar Pemrograman Berbasis Mobile – Kelompok 5** 🌟

## 🗳️ **Aplikasi Kosakata Inggris – *Wordly***


## 👥 **Anggota Kelompok**

| Nama                  | NPM        |
| --------------------- | ---------- |
| Arsya Yan Duribta     | 4522210117 |
| Agil Deriansyah Hasan | 4522210125 |

---

## 🌐 **Deskripsi Aplikasi**

**Wordly** adalah aplikasi seluler yang dirancang untuk membantu pengguna mempelajari, mengelola, dan menguji kosakata bahasa Inggris mereka.
Fokus utama aplikasi ini adalah antarmuka yang intuitif, tema yang dapat disesuaikan, dan pengalaman belajar yang interaktif melalui kuis serta fitur pelacakan kemajuan.

---

## 🎯 **Tujuan Utama**

* Menyediakan sistem manajemen kosakata pribadi: menyimpan kata, definisi, dan contoh.
* Mempermudah belajar kosakata melalui kuis interaktif.
* Melacak performa pengguna dari waktu ke waktu.
* Menjamin data tetap tersimpan secara lokal meskipun aplikasi ditutup.

---

## 🛠 **Teknologi yang Digunakan**

| Teknologi                       | Fungsi / Deskripsi                                                           |
| ------------------------------- | ---------------------------------------------------------------------------- |
| Flutter                         | Framework utama untuk pengembangan aplikasi mobile dan web.                  |
| Sqflite                         | Database SQLite lokal untuk menyimpan data kosakata, user, dan riwayat kuis. |
| http                            | Untuk memanggil API eksternal (dictionaryapi.dev, random-word-api).          |
| cupertino\_icons                | Ikon bergaya iOS untuk antarmuka.                                            |
| flutter\_adaptive\_scaffold     | Scaffold responsif agar UI adaptif di mobile, tablet, dan desktop.           |
| path                            | Mengelola path file di penyimpanan lokal.                                    |
| sqflite\_common\_ffi & ffi\_web | Dukungan SQLite di desktop dan web.                                          |
| image\_picker                   | Memilih foto profil dari galeri atau kamera.                                 |
| confetti                        | Efek konfeti saat pengguna mendapat skor sempurna di kuis.                   |
| flip\_card                      | Widget kartu balik interaktif untuk kosakata.                                |

---

## 🚀 **Fitur Utama**

### 🔑 Otentikasi

* Login dan registrasi akun.
* Manajemen sesi login menggunakan state di MyApp.

---

### 📚 Manajemen Kosakata

* Cari definisi kata secara daring.
* Simpan kata beserta definisi dan contoh.
* Lihat daftar kata tersimpan.
* Edit atau hapus kata yang sudah disimpan.
* Tampilkan kata sebagai *flip card* (kartu depan–belakang).
* Semua data disimpan di database lokal SQLite.

---

### 🧪 Kuis Interaktif

* Buat kuis dari kata acak melalui API.
* Pilih tingkat kesulitan atau kategori kata.
* Menjawab kuis berbasis definisi.
* Hitung dan tampilkan skor.
* Simpan hasil kuis sebagai riwayat.
* Efek konfeti untuk hasil sempurna.

---

### 📊 Pelacakan Kemajuan

* Lihat riwayat kuis lengkap.
* Klik riwayat untuk melihat detail: skor, tanggal, level, jenis kata, dan soal.
* Tampilan responsif berbasis grid.

---

### 👤 Profil & Pengaturan

* Lihat dan edit profil (nama, email, kata sandi, foto).
* Ganti foto profil dari galeri.
* Ganti tema warna (Biru, Krem, Hijau Hutan).
* Mode gelap / terang.
* Logout akun.

---

## 🗄️ **Model Data**

| *Model*           | *Atribut*                                                                                                                        |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **User**        | userId (PK), name, email, password, imagePath (nullable)                                                                       |
| **Word**        | id (PK), userId (FK), name, description, example                                                                               |
| **QuizWord**    | word, definition, partOfSpeech                                                                                                 |
| **QuizHistory** | id (PK), userId (FK), score, totalQuestions, level, partOfSpeech, date, questions (*disimpan sebagai JSON string di database*) |

---

## 💾 **Struktur Database**

* Database SQLite lokal (Sqflite).
* Tabel:

  * users → data user.
  * words → kata-kata tersimpan.
  * quiz_histories → hasil riwayat kuis.
* Kolom questions pada quiz_histories disimpan sebagai JSON string.
* Pengelolaan database dibantu oleh:

  * DatabaseHelper.instance → untuk data user & kata.
  * DatabaseHelperQuiz → untuk data riwayat kuis.

---

## ✨ **Ringkasan**

Aplikasi **Wordly** diharapkan dapat menjadi teman belajar kosakata yang interaktif, rapi, dan mudah digunakan, membantu pengguna memperkaya kosakata serta memantau progres belajarnya dengan cara yang menyenangkan.

---