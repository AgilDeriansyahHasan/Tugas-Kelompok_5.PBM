// Halaman untuk menghapus seluruh database secara manual
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  Future<void> _deleteDatabase(BuildContext context) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_database.db');
    try {
      await deleteDatabase(path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus database: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hapus Database')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete_forever),
          label: const Text('Hapus Semua Data'),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin menghapus seluruh database?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirm == true) {
              await _deleteDatabase(context);
            }
          },
        ),
      ),
    );
  }
}
