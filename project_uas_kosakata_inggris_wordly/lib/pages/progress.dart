// pages/progress_page.dart

import 'package:flutter/material.dart';

/// Halaman placeholder untuk fitur 'Progress'.
/// Saat ini hanya menampilkan pesan statis.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your progress data will be shown here.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class KemajuanPage extends StatelessWidget {
//   const KemajuanPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kemajuan'),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: const Center(
//         child: Text(
//           'Belum ada data kemajuan',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
