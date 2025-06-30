import 'package:flutter/material.dart';

class TinjauPage extends StatelessWidget {
  const TinjauPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinjau'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Halaman Tinjau Kosong',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
