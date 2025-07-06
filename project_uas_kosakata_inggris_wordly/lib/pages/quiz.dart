// pages/review_page.dart

import 'package:flutter/material.dart';

/// Halaman placeholder untuk fitur 'Review'.
/// Saat ini hanya menampilkan pesan statis.
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Review feature is coming soon!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
//
// class TinjauPage extends StatelessWidget {
//   const TinjauPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tinjau'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: const Center(
//         child: Text(
//           'Halaman Tinjau Kosong',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
