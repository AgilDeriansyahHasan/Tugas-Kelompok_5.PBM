// models/word_model.dart

/// Model data untuk sebuah kata (vocabulary).
/// Ini merepresentasikan tabel 'words' di database.
class Word {
  final int? id; // ID bisa null jika objek belum disimpan di database.
  final int userId;
  String name;
  String description;
  String example;
  bool isDone;

  Word({
    this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.example = '',
    this.isDone = false,
  });

  /// Konversi objek Word menjadi Map.
  /// Kunci (key) harus cocok dengan nama kolom di tabel database.
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'example': example,
    'isDone': isDone ? 1 : 0, // SQLite tidak punya tipe boolean, jadi gunakan 1/0.
  };

  /// Factory constructor untuk membuat objek Word dari Map.
  /// Ini digunakan saat mengambil data dari database.
  factory Word.fromMap(Map<String, dynamic> map) => Word(
    id: map['id'] as int,
    userId: map['userId'] as int,
    name: map['name'] as String,
    description: map['description'] ?? '', // Handle jika nilai null.
    example: map['example'] ?? '', // Handle jika nilai null.
    isDone: map['isDone'] == 1,
  );
}