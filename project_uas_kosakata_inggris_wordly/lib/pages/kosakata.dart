import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../model/habit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class KosakataPage extends StatefulWidget {
  const KosakataPage({Key? key}) : super(key: key);

  @override
  _KosakataPageState createState() => _KosakataPageState();
}

class _KosakataPageState extends State<KosakataPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<WordEntry> _entries = [];
  List<Habit> _saved = [];
  bool _dbLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _loadSaved();
    _controller.addListener(() => setState(() {}));
  }

  Future<void> _loadSaved() async {
    setState(() => _dbLoading = true);
    _saved = await DatabaseHelper.instance.getAllHabits();
    setState(() => _dbLoading = false);
  }

  Future<void> _fetchWord(String word) async {
    if (word.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _entries.clear();
    });
    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _entries = data.map((e) => WordEntry.fromJson(e)).toList();
      } else {
        _error = 'Word not found.';
      }
    } catch (_) {
      _error = 'Error fetching data.';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntry(WordEntry entry) async {
    final m = entry.meanings.isNotEmpty ? entry.meanings.first : null;
    final d = m?.definitions.first;
    final newItem = Habit(
      id: _saved.isEmpty ? 1 : _saved.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1,
      name: entry.word,
      description: d?.definition ?? '',
      example: d?.example ?? '',
      isDone: false,
    );
    await DatabaseHelper.instance.insertHabit(newItem);
    await _loadSaved();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${entry.word}" disimpan')));
  }

  List<Habit> get _filteredSaved {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return _saved;
    return _saved.where((h) => h.name.toLowerCase().contains(q)).toList();
  }

  void _showSavedDialog(Habit habit) {
    final nameCtrl = TextEditingController(text: habit.name);
    final descCtrl = TextEditingController(text: habit.description);
    final exampleCtrl = TextEditingController(text: habit.example);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detail Kosakata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Kata'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: exampleCtrl,
                decoration: const InputDecoration(labelText: 'Contoh'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteHabit(habit.id);
                      Navigator.pop(ctx);
                      await _loadSaved();
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      habit.name = nameCtrl.text;
                      habit.description = descCtrl.text;
                      habit.example = exampleCtrl.text;
                      await DatabaseHelper.instance.updateHabit(habit);
                      Navigator.pop(ctx);
                      await _loadSaved();
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kosakata'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan kata Inggris',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _fetchWord,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _fetchWord(_controller.text.trim()),
                  child: const Text('Cari'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_entries.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (ctx, i) {
                      final e = _entries[i];
                      final m = e.meanings.isNotEmpty ? e.meanings.first : null;
                      final d = m?.definitions.first;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Definition: ${d?.definition ?? '-'}'),
                              const SizedBox(height: 4),
                              Text('Example: ${d?.example ?? '-'}'),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => _saveEntry(e),
                                  child: const Text('Simpan'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            const Divider(),
            Expanded(
              child: _dbLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSaved.isEmpty
                  ? const Center(child: Text('Tidak ada data sesuai pencarian'))
                  : ListView.builder(
                itemCount: _filteredSaved.length,
                itemBuilder: (ctx, i) {
                  final h = _filteredSaved[i];
                  return ListTile(
                    title: Text(h.name),
                    subtitle: Text(h.description),
                    onTap: () => _showSavedDialog(h),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models for API
class WordEntry {
  final String word;
  final List<Meaning> meanings;
  WordEntry({required this.word, required this.meanings});
  factory WordEntry.fromJson(Map<String, dynamic> json) {
    final meanings = (json['meanings'] as List).map((m) => Meaning.fromJson(m)).toList();
    return WordEntry(word: json['word'], meanings: meanings);
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  Meaning({required this.partOfSpeech, required this.definitions});
  factory Meaning.fromJson(Map<String, dynamic> json) {
    final defs = (json['definitions'] as List).map((d) => Definition.fromJson(d)).toList();
    return Meaning(partOfSpeech: json['partOfSpeech'], definitions: defs);
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  Definition({required this.definition, this.example, required this.synonyms});
  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'],
      example: json['example'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
    );
  }
}

// ==================================================

// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:http/http.dart' as http;
// import '../database/database_helper.dart';
// import '../model/habit.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
//
//
// class KosakataPage extends StatefulWidget {
//   const KosakataPage({Key? key}) : super(key: key);
//
//   @override
//   _KosakataPageState createState() => _KosakataPageState();
// }
//
// class _KosakataPageState extends State<KosakataPage> {
//   final TextEditingController _controller = TextEditingController();
//   bool _isLoading = false;
//   String? _error;
//   List<WordEntry> _entries = [];
//   List<Habit> _saved = [];
//   bool _dbLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
//       sqfliteFfiInit();
//       databaseFactory = databaseFactoryFfi;
//     }
//     _loadSaved();
//     _controller.addListener(() {
//       setState(() {});
//     });
//   }
//
//   Future<void> _loadSaved() async {
//     setState(() => _dbLoading = true);
//     _saved = await DatabaseHelper.instance.getAllHabits();
//     setState(() => _dbLoading = false);
//   }
//
//   Future<void> _fetchWord(String word) async {
//     if (word.isEmpty) return;
//     setState(() {
//       _isLoading = true;
//       _error = null;
//       _entries.clear();
//     });
//     final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final List data = json.decode(response.body);
//         _entries = data.map((e) => WordEntry.fromJson(e)).toList();
//       } else {
//         _error = 'Word not found.';
//       }
//     } catch (e) {
//       _error = 'Error fetching data.';
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _saveEntry(WordEntry entry) async {
//     final m = entry.meanings.isNotEmpty ? entry.meanings.first : null;
//     final d = m?.definitions.first;
//     final newItem = Habit(
//       id: _saved.isEmpty ? 1 : _saved.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1,
//       name: entry.word,
//       description: d?.definition ?? '',
//       example: d?.example ?? '',
//       isDone: false,
//     );
//     await DatabaseHelper.instance.insertHabit(newItem);
//     await _loadSaved();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${entry.word}" disimpan')));
//   }
//
//   List<Habit> get _filteredSaved {
//     final q = _controller.text.trim().toLowerCase();
//     if (q.isEmpty) return _saved;
//     return _saved.where((h) => h.name.toLowerCase().contains(q)).toList();
//   }
//
//   void _showSavedDialog(Habit habit) {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         final nameCtrl = TextEditingController(text: habit.name);
//         final descCtrl = TextEditingController(text: habit.description);
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Detail Kosakata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
//                   ],
//                 ),
//                 TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Kata')),
//                 TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(onPressed: () async {
//                       await DatabaseHelper.instance.deleteHabit(habit.id);
//                       Navigator.pop(ctx);
//                       await _loadSaved();
//                     }, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
//                     const SizedBox(width: 8),
//                     ElevatedButton(onPressed: () async {
//                       habit.name = nameCtrl.text;
//                       habit.description = descCtrl.text;
//                       await DatabaseHelper.instance.updateHabit(habit);
//                       Navigator.pop(ctx);
//                       await _loadSaved();
//                     }, child: const Text('Simpan')),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Kosakata'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(hintText: 'Masukkan kata Inggris', border: OutlineInputBorder()),
//                   onSubmitted: _fetchWord,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(onPressed: () => _fetchWord(_controller.text.trim()), child: const Text('Cari')),
//             ]),
//             const SizedBox(height: 16),
//             if (_isLoading) const CircularProgressIndicator()
//             else if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red))
//             else if (_entries.isNotEmpty)
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _entries.length,
//                     itemBuilder: (ctx, i) {
//                       final e = _entries[i];
//                       final m = e.meanings.isNotEmpty ? e.meanings.first : null;
//                       final d = m?.definitions.first;
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(e.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 8),
//                               Text('Definition: ${d?.definition ?? '-'}'),
//                               const SizedBox(height: 4),
//                               Text('Example: ${d?.example ?? '-'}'),
//                               Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                                 ElevatedButton(onPressed: () => _saveEntry(e), child: const Text('Simpan'))
//                               ]),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//             const Divider(),
//             Expanded(
//               child: _dbLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _filteredSaved.isEmpty
//                   ? const Center(child: Text('Tidak ada data sesuai pencarian'))
//                   : ListView.builder(
//                 itemCount: _filteredSaved.length,
//                 itemBuilder: (ctx, i) {
//                   final h = _filteredSaved[i];
//                   return ListTile(
//                     title: Text(h.name),
//                     subtitle: Text(h.description),
//                     onTap: () => _showSavedDialog(h),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Models for API
// class WordEntry {
//   final String word;
//   final List<Meaning> meanings;
//   WordEntry({required this.word, required this.meanings});
//   factory WordEntry.fromJson(Map<String, dynamic> json) {
//     final meanings = (json['meanings'] as List).map((m) => Meaning.fromJson(m)).toList();
//     return WordEntry(word: json['word'], meanings: meanings);
//   }
// }
//
// class Meaning {
//   final String partOfSpeech;
//   final List<Definition> definitions;
//   Meaning({required this.partOfSpeech, required this.definitions});
//   factory Meaning.fromJson(Map<String, dynamic> json) {
//     final defs = (json['definitions'] as List).map((d) => Definition.fromJson(d)).toList();
//     return Meaning(partOfSpeech: json['partOfSpeech'], definitions: defs);
//   }
// }
//
// class Definition {
//   final String definition;
//   final String? example;
//   final List<String> synonyms;
//   Definition({required this.definition, this.example, required this.synonyms});
//   factory Definition.fromJson(Map<String, dynamic> json) {
//     return Definition(
//       definition: json['definition'],
//       example: json['example'],
//       synonyms: List<String>.from(json['synonyms'] ?? []),
//     );
//   }
// }
//
//
// // =================================================
//
// // import 'dart:io' show Platform;
// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:http/http.dart' as http;
// // import '../database/database_helper.dart';
// // import '../model/habit.dart';
// // import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// // import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// //
// // class KosakataPage extends StatefulWidget {
// //   const KosakataPage({Key? key}) : super(key: key);
// //
// //   @override
// //   _KosakataPageState createState() => _KosakataPageState();
// // }
// //
// // class _KosakataPageState extends State<KosakataPage> {
// //   final TextEditingController _controller = TextEditingController();
// //   bool _isLoading = false;
// //   String? _error;
// //   List<WordEntry> _entries = [];
// //
// //   // saved vocabularies from local DB
// //   List<Habit> _saved = [];
// //   bool _dbLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize sqflite ffi only on desktop platforms; on mobile, default sqflite is used
// //     if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
// //       sqfliteFfiInit();
// //       databaseFactory = databaseFactoryFfi;
// //     }
// //     _loadSaved();
// //   }
// //
// //   Future<void> _loadSaved() async {
// //     setState(() => _dbLoading = true);
// //     try {
// //       _saved = await DatabaseHelper.instance.getAllHabits();
// //     } catch (e) {
// //       debugPrint('Error loading saved words: $e');
// //       _saved = [];
// //     }
// //     setState(() => _dbLoading = false);
// //   }
// //
// //   Future<void> _fetchWord(String word) async {
// //     if (word.isEmpty) return;
// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //       _entries.clear();
// //     });
// //
// //     final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
// //     try {
// //       final response = await http.get(url);
// //       if (response.statusCode == 200) {
// //         final List data = json.decode(response.body);
// //         _entries = data.map((e) => WordEntry.fromJson(e)).toList();
// //       } else {
// //         _error = 'Word not found.';
// //       }
// //     } catch (e) {
// //       _error = 'Error fetching data.';
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   Future<void> _saveEntry(WordEntry entry) async {
// //     final m = entry.meanings.isNotEmpty ? entry.meanings.first : null;
// //     final d = m?.definitions.isNotEmpty == true ? m!.definitions.first : null;
// //     final newItem = Habit(
// //       id: _getNewId(),
// //       name: entry.word,
// //       description: d?.definition ?? '',
// //       example: d?.example ?? '',
// //       isDone: false,
// //     );
// //     await DatabaseHelper.instance.insertHabit(newItem);
// //     await _loadSaved();
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(SnackBar(content: Text('"${entry.word}" disimpan')));
// //   }
// //
// //   int _getNewId() => _saved.isEmpty ? 1 : _saved.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1;
// //
// //   void _showEditDialog(Habit habit, int index) {
// //     final nameCtrl = TextEditingController(text: habit.name);
// //     final descCtrl = TextEditingController(text: habit.description);
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         title: const Text('Edit Kosakata'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Kata')),
// //             TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
// //           ElevatedButton(
// //             onPressed: () async {
// //               habit.name = nameCtrl.text;
// //               habit.description = descCtrl.text;
// //               await DatabaseHelper.instance.updateHabit(habit);
// //               Navigator.pop(ctx);
// //               await _loadSaved();
// //             },
// //             child: const Text('Simpan'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _confirmDelete(int id) {
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         title: const Text('Hapus Kosakata'),
// //         content: const Text('Yakin ingin menghapus?'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
// //           TextButton(
// //             onPressed: () async {
// //               await DatabaseHelper.instance.deleteHabit(id);
// //               Navigator.pop(ctx);
// //               await _loadSaved();
// //             },
// //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// //             child: const Text('Hapus'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Kosakata'), centerTitle: true),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _controller,
// //                     decoration: const InputDecoration(hintText: 'Masukkan kata Inggris', border: OutlineInputBorder()),
// //                     onSubmitted: _fetchWord,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 ElevatedButton(onPressed: () => _fetchWord(_controller.text.trim()), child: const Text('Cari')),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             if (_isLoading) const CircularProgressIndicator()
// //             else if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red))
// //             else if (_entries.isNotEmpty)
// //                 Expanded(
// //                   child: ListView.builder(
// //                     itemCount: _entries.length,
// //                     itemBuilder: (ctx, i) {
// //                       final e = _entries[i];
// //                       final m = e.meanings.isNotEmpty ? e.meanings.first : null;
// //                       final d = m?.definitions.first;
// //                       return Card(
// //                         margin: const EdgeInsets.symmetric(vertical: 8),
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(16),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(e.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// //                               const SizedBox(height: 8),
// //                               Text('Definition: ${d?.definition ?? '-'}'),
// //                               const SizedBox(height: 4),
// //                               Text('Example: ${d?.example ?? '-'}'),
// //                               Row(
// //                                 mainAxisAlignment: MainAxisAlignment.end,
// //                                 children: [
// //                                   ElevatedButton(
// //                                     onPressed: () => _saveEntry(e),
// //                                     child: const Text('Simpan'),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //             const Divider(),
// //             Expanded(
// //               child: _dbLoading
// //                   ? const Center(child: CircularProgressIndicator())
// //                   : _saved.isEmpty
// //                   ? const Center(child: Text('Belum ada yang disimpan'))
// //                   : ListView.builder(
// //                 itemCount: _saved.length,
// //                 itemBuilder: (ctx, i) {
// //                   final h = _saved[i];
// //                   return Card(
// //                     margin: const EdgeInsets.symmetric(vertical: 6),
// //                     child: ListTile(
// //                       title: Text(h.name),
// //                       subtitle: Text(h.description),
// //                       trailing: PopupMenuButton<String>(
// //                         onSelected: (v) {
// //                           if (v == 'edit') _showEditDialog(h, i);
// //                           if (v == 'delete') _confirmDelete(h.id);
// //                         },
// //                         itemBuilder: (_) => [
// //                           const PopupMenuItem(value: 'edit', child: Text('Edit')),
// //                           const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Models for API
// // class WordEntry {
// //   final String word;
// //   final List<Meaning> meanings;
// //   WordEntry({required this.word, required this.meanings});
// //   factory WordEntry.fromJson(Map<String, dynamic> json) {
// //     final meanings = (json['meanings'] as List).map((m) => Meaning.fromJson(m)).toList();
// //     return WordEntry(word: json['word'], meanings: meanings);
// //   }
// // }
// //
// // class Meaning {
// //   final String partOfSpeech;
// //   final List<Definition> definitions;
// //   Meaning({required this.partOfSpeech, required this.definitions});
// //   factory Meaning.fromJson(Map<String, dynamic> json) {
// //     final defs = (json['definitions'] as List).map((d) => Definition.fromJson(d)).toList();
// //     return Meaning(partOfSpeech: json['partOfSpeech'], definitions: defs);
// //   }
// // }
// //
// // class Definition {
// //   final String definition;
// //   final String? example;
// //   final List<String> synonyms;
// //   Definition({required this.definition, this.example, required this.synonyms});
// //   factory Definition.fromJson(Map<String, dynamic> json) {
// //     return Definition(
// //       definition: json['definition'],
// //       example: json['example'],
// //       synonyms: List<String>.from(json['synonyms'] ?? []),
// //     );
// //   }
// // }
// //
// //
// // // ===================================================
// //
// // // import 'package:flutter/material.dart';
// // // import 'dart:convert';
// // // import 'package:http/http.dart' as http;
// // //
// // // class KosakataPage extends StatefulWidget {
// // //   const KosakataPage({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   _KosakataPageState createState() => _KosakataPageState();
// // // }
// // //
// // // class _KosakataPageState extends State<KosakataPage> {
// // //   final TextEditingController _controller = TextEditingController();
// // //   bool _isLoading = false;
// // //   List<WordEntry> _entries = [];
// // //   String? _error;
// // //
// // //   Future<void> _fetchWord(String word) async {
// // //     setState(() {
// // //       _isLoading = true;
// // //       _error = null;
// // //       _entries.clear();
// // //     });
// // //
// // //     final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
// // //     try {
// // //       final response = await http.get(url);
// // //       if (response.statusCode == 200) {
// // //         final List data = json.decode(response.body);
// // //         final entries = data.map((e) => WordEntry.fromJson(e)).toList();
// // //         setState(() {
// // //           _entries = entries;
// // //         });
// // //       } else {
// // //         setState(() {
// // //           _error = 'Word not found.';
// // //         });
// // //       }
// // //     } catch (e) {
// // //       setState(() {
// // //         _error = 'Error fetching data.';
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Kosakata'),
// // //         centerTitle: true,
// // //       ),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Column(
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: TextField(
// // //                     controller: _controller,
// // //                     decoration: const InputDecoration(
// // //                       hintText: 'Masukkan kata bahasa Inggris',
// // //                       border: OutlineInputBorder(),
// // //                     ),
// // //                     onSubmitted: _fetchWord,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 ElevatedButton(
// // //                   onPressed: () => _fetchWord(_controller.text.trim()),
// // //                   child: const Text('Cari'),
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 16),
// // //             if (_isLoading)
// // //               const CircularProgressIndicator()
// // //             else if (_error != null)
// // //               Text(
// // //                 _error!,
// // //                 style: const TextStyle(color: Colors.red),
// // //               )
// // //             else if (_entries.isEmpty)
// // //                 const Text('Belum ada hasil. Coba cari kata.'),
// // //             if (_entries.isNotEmpty)
// // //               Expanded(
// // //                 child: ListView.builder(
// // //                   itemCount: _entries.length,
// // //                   itemBuilder: (context, index) {
// // //                     final entry = _entries[index];
// // //                     final firstMeaning = entry.meanings.isNotEmpty ? entry.meanings.first : null;
// // //                     final firstDef = firstMeaning?.definitions.isNotEmpty == true ? firstMeaning!.definitions.first : null;
// // //                     final synonyms = firstDef?.synonyms.isNotEmpty == true ? firstDef!.synonyms.join(', ') : '-';
// // //                     return Card(
// // //                       margin: const EdgeInsets.symmetric(vertical: 8),
// // //                       child: Padding(
// // //                         padding: const EdgeInsets.all(16.0),
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               entry.word,
// // //                               style: const TextStyle(
// // //                                 fontSize: 20,
// // //                                 fontWeight: FontWeight.bold,
// // //                               ),
// // //                             ),
// // //                             const SizedBox(height: 8),
// // //                             Text('Synonyms: $synonyms'),
// // //                             const SizedBox(height: 4),
// // //                             Text('Definition: ${firstDef?.definition ?? '-'}'),
// // //                             const SizedBox(height: 4),
// // //                             Text('Example: ${firstDef?.example ?? '-'}'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // Models
// // // class WordEntry {
// // //   final String word;
// // //   final List<Meaning> meanings;
// // //
// // //   WordEntry({required this.word, required this.meanings});
// // //
// // //   factory WordEntry.fromJson(Map<String, dynamic> json) {
// // //     final meanings = (json['meanings'] as List)
// // //         .map((m) => Meaning.fromJson(m))
// // //         .toList();
// // //     return WordEntry(
// // //       word: json['word'],
// // //       meanings: meanings,
// // //     );
// // //   }
// // // }
// // //
// // // class Meaning {
// // //   final String partOfSpeech;
// // //   final List<Definition> definitions;
// // //
// // //   Meaning({required this.partOfSpeech, required this.definitions});
// // //
// // //   factory Meaning.fromJson(Map<String, dynamic> json) {
// // //     final defs = (json['definitions'] as List)
// // //         .map((d) => Definition.fromJson(d))
// // //         .toList();
// // //     return Meaning(
// // //       partOfSpeech: json['partOfSpeech'],
// // //       definitions: defs,
// // //     );
// // //   }
// // // }
// // //
// // // class Definition {
// // //   final String definition;
// // //   final String? example;
// // //   final List<String> synonyms;
// // //
// // //   Definition({required this.definition, this.example, required this.synonyms});
// // //
// // //   factory Definition.fromJson(Map<String, dynamic> json) {
// // //     return Definition(
// // //       definition: json['definition'],
// // //       example: json['example'],
// // //       synonyms: List<String>.from(json['synonyms'] ?? []),
// // //     );
// // //   }
// // // }