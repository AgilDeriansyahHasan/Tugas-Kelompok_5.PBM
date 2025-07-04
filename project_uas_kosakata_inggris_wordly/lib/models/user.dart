// models/user_model.dart

/// Model data untuk pengguna (user).
/// Ini merepresentasikan tabel 'users' di database.
class User {
  final int userId;
  String name;
  String email;
  String password;
  String? imagePath; // Path gambar profil bisa null.

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    this.imagePath,
  });

  /// Konversi objek User menjadi Map.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'password': password,
    'imagePath': imagePath,
  };

  /// Factory constructor untuk membuat objek User dari Map.
  factory User.fromMap(Map<String, dynamic> map) => User(
    userId: map['userId'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
    imagePath: map['imagePath'] as String?,
  );
}