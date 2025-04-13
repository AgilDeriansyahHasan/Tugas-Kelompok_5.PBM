import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HalamanUniversitas extends StatefulWidget {
  const HalamanUniversitas({super.key});

  @override
  _HalamanUniversitasState createState() => _HalamanUniversitasState();
}

class _HalamanUniversitasState extends State<HalamanUniversitas> {
  List universitas = [];
  bool loading = true;

  Future<void> fetchUniversitas() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=Indonesia'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      data.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

      setState(() {
        universitas = data;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUniversitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: universitas.length,
        itemBuilder: (context, index) {
          final univ = universitas[index];
          final namaUniv = univ['name'] ?? '';
          final webPage = (univ['web_pages'] != null && univ['web_pages'].isNotEmpty)
              ? univ['web_pages'][0]
              : '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // CONTAINER tetap putih
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaUniv,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  webPage,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
