# 🌟 Aplikasi Flutter 3 Halaman - Kelompok 5 🌟

## 👥 Anggota Kelompok
| Nama                  | NPM        |
|-----------------------|------------|
| Agil Deriansyah Hasan | 4522210125 |
| Arsya Yan Duribta     | 4522210117 |

---

## 🌐 Deskripsi Aplikasi

Aplikasi ini berisi 3 halaman, yaitu:
1. Counter sederhana.
2. Menampilkan data dari API.
3. Profil anggota kelompok.

## 📸 Hasil Screenshot

### Halaman Counter
![Counter](screenshot/counter.png)

### Halaman Counter
![Counter](screenshot/universitas.png)

### Halaman Profile
![Profile](screenshot/profile.png)

## Penjelasan Tiap Halaman:
- **Halaman Counter:** `HalamanUtama` adalah halaman yang menampilkan penghitung angka (counter) sederhana. Di dalam `_HalamanUtamaState`, terdapat variabel `_counter` untuk menyimpan jumlah angka saat ini. Dua fungsi, yaitu `_incrementCounter()` dan `_decrementCounter()`, digunakan untuk menambah atau mengurangi nilai `_counter`, masing-masing memanggil `setState()` agar perubahan nilai segera memperbarui tampilan. Bagian tampilan utama menampilkan teks "Jumlah Angka" sebagai judul, diikuti oleh `AnimatedContainer` yang memamerkan nilai counter dengan animasi halus setiap kali terjadi perubahan. Di bawahnya, terdapat dua tombol berbentuk bulat `(_circleButton)` yang masing-masing berfungsi untuk mengurangi `(Icons.remove)` dan menambah `(Icons.add)` nilai counter.
  
- **Halaman API:** `HalamanUniversitas` adalah halaman yang berfungsi untuk mengambil dan menampilkan daftar universitas di Indonesia menggunakan API dari **Hipolabs Universities API**. Saat halaman pertama kali dibuka, method `initState()` akan memanggil fungsi `fetchUniversitas()`, yang melakukan HTTP GET request ke endpoint `http://universities.hipolabs.com/search?country=Indonesia`. Selama data sedang diambil, halaman menampilkan widget `CircularProgressIndicator` di tengah layar sebagai indikator loading. Jika respons berhasil dengan status code 200, data JSON yang diterima di-decode menjadi list, lalu diurutkan secara alfabet berdasarkan nama universitas menggunakan `sort()`. Setelah proses pengurutan selesai, `setState()` dipanggil untuk menyimpan data ke variabel universitas dan mengubah status loading menjadi false, sehingga tampilan halaman otomatis diperbarui.<br>
Saat status loading sudah false, daftar universitas ditampilkan menggunakan `ListView.builder`. Setiap item universitas dirender dalam sebuah `Container` berwarna putih, menampilkan nama universitas dengan teks tebal, serta alamat website (jika tersedia) dalam teks berwarna biru, diambil dari elemen pertama `web_pages`. Jika terjadi kegagalan pengambilan data, halaman hanya menghilangkan indikator loading tanpa menampilkan data apapun. Pengelolaan state dilakukan sepenuhnya melalui `setState()` secara sederhana agar tampilan pengguna selalu sinkron dengan kondisi data terbaru, baik saat loading, berhasil memuat data, maupun saat terjadi error.
  
- **Halaman Profil:** HalamanProfile adalah halaman yang menampilkan daftar profil dalam format kartu menggunakan `ListView`. Setiap profil ditampilkan melalui widget `_buildProfileCard`, yang menerima parameter berupa path gambar, nama, tempat tanggal lahir, dan alamat. Di dalam kartu, gambar profil ditampilkan di atas dengan ukuran yang konsisten (120x160 piksel) dan sudut melengkung `(ClipRRect)`, diikuti oleh garis pemisah `(Divider)` sebelum menampilkan informasi detail seperti nama, TTL, dan alamat. Informasi ini disusun dalam bentuk baris dengan label tebal diikuti oleh nilainya, menggunakan fungsi `_buildInfoRow` untuk menjaga konsistensi tampilan.


## Cara Menjalankan Aplikasi:

flutter pub get flutter run
