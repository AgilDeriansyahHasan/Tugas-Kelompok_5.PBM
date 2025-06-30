import 'package:flutter/material.dart';

class KemajuanPage extends StatelessWidget {
  const KemajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemajuan'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Belum ada data kemajuan',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
