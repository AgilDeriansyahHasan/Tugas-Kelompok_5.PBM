// pages/vocabulary_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../models/user.dart';
import '../models/word.dart';

class VocabularyPage extends StatefulWidget {
  final User currentUser;
  const VocabularyPage({super.key, required this.currentUser});

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final TextEditingController _searchController = TextEditingController();

  // State untuk mengelola hasil pencarian dari API.
  bool _isApiLoading = false;
  String? _apiError;
  List<ApiWordEntry> _apiEntries = [];

  // State untuk mengelola kata yang disimpan di database lokal.
  bool _isDbLoading = true;
  List<Word> _savedWords = [];
  List<Word> _filteredSavedWords = [];

  @override
  void initState() {
    super.initState();
    _loadSavedWords(); // Muat kata yang sudah tersimpan saat halaman dibuka.
    // Tambahkan listener untuk memfilter daftar kata yang disimpan saat pengguna mengetik.
    _searchController.addListener(_filterSavedWords);
  }

  /// Memuat daftar kata yang telah disimpan oleh pengguna dari database.
  Future<void> _loadSavedWords() async {
    setState(() => _isDbLoading = true);
    final words = await DatabaseHelper.instance.getWords(widget.currentUser.userId);
    setState(() {
      _savedWords = words;
      _filteredSavedWords = words; // Awalnya, daftar yang difilter sama dengan daftar penuh.
      _isDbLoading = false;
    });
  }

  /// Memfilter daftar kata yang disimpan berdasarkan input di search bar.
  void _filterSavedWords() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSavedWords = _savedWords
          .where((word) => word.name.toLowerCase().contains(query))
          .toList();
    });
  }

  /// Mengambil definisi kata dari API publik.
  Future<void> _fetchWordFromApi(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isApiLoading = true;
      _apiError = null;
      _apiEntries.clear();
    });

    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _apiEntries = data.map((e) => ApiWordEntry.fromJson(e)).toList();
      } else {
        _apiError = 'Sorry, the word could not be found.';
      }
    } catch (_) {
      _apiError = 'Failed to connect. Please check your internet connection.';
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  /// Menyimpan kata dari hasil pencarian API ke database lokal.
  Future<void> _saveApiEntry(ApiWordEntry entry) async {
    final meaning = entry.meanings.isNotEmpty ? entry.meanings.first : null;
    final definition = meaning?.definitions.first;

    final newWord = Word(
      userId: widget.currentUser.userId,
      name: entry.word,
      description: definition?.definition ?? 'No definition available.',
      example: definition?.example ?? 'No example available.',
    );

    await DatabaseHelper.instance.insertWord(newWord);
    await _loadSavedWords(); // Muat ulang daftar kata setelah menyimpan.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${entry.word}" has been saved.')),
    );
  }

  /// Menampilkan dialog untuk melihat, mengedit, atau menghapus kata yang sudah disimpan.
  void _showWordDetailDialog(Word word) {
    final nameController = TextEditingController(text: word.name);
    final descController = TextEditingController(text: word.description);
    final exampleController = TextEditingController(text: word.example);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Word Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Word')),
              const SizedBox(height: 8),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: exampleController, decoration: const InputDecoration(labelText: 'Example'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Tampilkan dialog konfirmasi sebelum menghapus.
              final confirm = await showDialog<bool>(
                context: context,
                builder: (confirmCtx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete "${word.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(confirmCtx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(confirmCtx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await DatabaseHelper.instance.deleteWord(word.id!);
                Navigator.pop(ctx); // Tutup dialog detail
                _loadSavedWords(); // Muat ulang
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              word.name = nameController.text;
              word.description = descController.text;
              word.example = exampleController.text;
              await DatabaseHelper.instance.updateWord(word);
              Navigator.pop(ctx);
              _loadSavedWords();
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search online or in your list...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.travel_explore),
                  tooltip: 'Search Online',
                  onPressed: () => _fetchWordFromApi(_searchController.text.trim()),
                ),
              ),
              onSubmitted: _fetchWordFromApi,
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Search Results'),
              Tab(text: 'My Saved Words'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildApiResultView(),
                _buildSavedWordsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan hasil pencarian dari API.
  Widget _buildApiResultView() {
    if (_isApiLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiError != null) {
      return Center(child: Text(_apiError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)));
    }
    if (_apiEntries.isEmpty) {
      return const Center(child: Text('Search for a word to see results here.'));
    }
    return ListView.builder(
      itemCount: _apiEntries.length,
      itemBuilder: (ctx, i) {
        final entry = _apiEntries[i];
        final meaning = entry.meanings.isNotEmpty ? entry.meanings.first : null;
        final definition = meaning?.definitions.first;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (meaning != null)
                  Text(meaning.partOfSpeech, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('Definition: ${definition?.definition ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text('Example: ${definition?.example ?? 'N/A'}'),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    tooltip: 'Save Word',
                    onPressed: () => _saveApiEntry(entry),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget untuk menampilkan daftar kata yang disimpan.
  Widget _buildSavedWordsView() {
    if (_isDbLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredSavedWords.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'You have no saved words yet.'
              : 'No saved words match your search.',
        ),
      );
    }
    return ListView.builder(
      itemCount: _filteredSavedWords.length,
      itemBuilder: (ctx, i) {
        final word = _filteredSavedWords[i];
        return ListTile(
          title: Text(word.name),
          subtitle: Text(word.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => _showWordDetailDialog(word),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}


// --- Model-model untuk parsing data dari Dictionary API ---

class ApiWordEntry {
  final String word;
  final List<ApiMeaning> meanings;
  ApiWordEntry({required this.word, required this.meanings});
  factory ApiWordEntry.fromJson(Map<String, dynamic> json) {
    final meanings = (json['meanings'] as List).map((m) => ApiMeaning.fromJson(m)).toList();
    return ApiWordEntry(word: json['word'], meanings: meanings);
  }
}

class ApiMeaning {
  final String partOfSpeech;
  final List<ApiDefinition> definitions;
  ApiMeaning({required this.partOfSpeech, required this.definitions});
  factory ApiMeaning.fromJson(Map<String, dynamic> json) {
    final defs = (json['definitions'] as List).map((d) => ApiDefinition.fromJson(d)).toList();
    return ApiMeaning(partOfSpeech: json['partOfSpeech'], definitions: defs);
  }
}

class ApiDefinition {
  final String definition;
  final String? example;
  ApiDefinition({required this.definition, this.example});
  factory ApiDefinition.fromJson(Map<String, dynamic> json) {
    return ApiDefinition(
      definition: json['definition'],
      example: json['example'],
    );
  }
}
