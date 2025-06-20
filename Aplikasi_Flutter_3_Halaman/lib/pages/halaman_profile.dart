import 'package:flutter/material.dart';

class HalamanProfile extends StatelessWidget {
  const HalamanProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Mengatur warna latar agar tetap bersih
      body: ListView(
        padding: const EdgeInsets.all(16), // Memberi padding di sekeliling ListView
        children: [
          // Menampilkan kartu profil pertama
          _buildProfileCard(
            imagePath: 'assets/images/agil.jpg',
            nama: 'Agil Deriansyah Hasan',
            ttl: 'Bekasi, 28 Juli 2004',
            alamat: 'Jl. Bintara 14, Bekasi',
          ),
          const SizedBox(height: 16), // Jarak antar kartu

          // Menampilkan kartu profil kedua
          _buildProfileCard(
            imagePath: 'assets/images/arsya.jpeg',
            nama: 'Arsya Yan Duribta',
            ttl: 'Sukabumi, 6 Januari 2003',
            alamat: 'Jl. Lauser I, Jakarta Selatan',
          ),
        ],
      ),
    );
  }

  // Fungsi `_buildProfileCard` membuat widget `Card` untuk menampilkan data profil.
  // Parameternya adalah path gambar, nama, TTL, dan alamat.
  Widget _buildProfileCard({
    required String imagePath,
    required String nama,
    required String ttl,
    required String alamat,
  }) {
    return Card(
      color: Colors.white, // Warna latar kartu
      elevation: 3, // Efek bayangan
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Sudut kartu melengkung
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Menampilkan gambar profil
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 160,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Menyesuaikan ukuran gambar ke dalam kotak
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(), // Garis pemisah
            const SizedBox(height: 12),

            // Baris-baris informasi
            _buildInfoRow(label: 'Nama', value: nama),
            _buildInfoRow(label: 'Tempat, Tanggal Lahir', value: ttl),
            _buildInfoRow(label: 'Alamat', value: alamat),
          ],
        ),
      ),
    );
  }

  // Fungsi `_buildInfoRow` membuat baris informasi dengan label dan nilai.
  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label ditampilkan dengan huruf tebal
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // Nilai ditampilkan mengikuti lebar baris
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
