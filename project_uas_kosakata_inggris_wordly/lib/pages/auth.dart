// pages/auth.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../main.dart';
import '../models/user.dart';

// Enum untuk menentukan mode halaman: Login atau Register.
enum AuthMode { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Kunci global untuk mengelola state dari Form.
  final _formKey = GlobalKey<FormState>();

  // Mode awal adalah Login.
  AuthMode _mode = AuthMode.login;

  // Controller untuk setiap field input.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk loading dan pesan error.
  bool _isLoading = false;
  String? _errorMessage;

  /// Fungsi yang dipanggil saat tombol utama (Login/Register) ditekan.
  Future<void> _submit() async {
    // Validasi form terlebih dahulu. Jika tidak valid, hentikan proses.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ubah state untuk menampilkan indikator loading dan menghapus pesan error lama.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final db = DatabaseHelper.instance;

    try {
      if (_mode == AuthMode.register) {
        // --- LOGIKA REGISTER ---
        // Buat objek User baru dari data yang diinput.
        final newUser = User(
          // Gunakan timestamp sebagai ID unik sederhana.
          userId: DateTime.now().millisecondsSinceEpoch,
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text.trim(),
        );

        // Masukkan pengguna baru ke database.
        await db.insertUser(newUser);

        // Tampilkan pesan sukses dan ganti mode ke Login.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login.')),
        );
        _switchAuthMode(); // Pindah ke halaman login setelah register.

      } else {
        // --- LOGIKA LOGIN ---
        // Autentikasi pengguna menggunakan email dan password.
        final user = await db.authenticate(
          _emailController.text.trim().toLowerCase(),
          _passwordController.text.trim(),
        );

        if (user == null) {
          // Jika user tidak ditemukan, tampilkan pesan error.
          setState(() {
            _errorMessage = 'Invalid email or password.';
          });
        } else {
          // Jika berhasil, panggil `setAuthentication` dari MyApp untuk mengubah state global.
          MyApp.of(context).setAuthentication(true, user: user);
        }
      }
    } catch (e) {
      // Tangani error, misalnya jika email sudah terdaftar.
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }

    // Hentikan loading setelah proses selesai.
    setState(() {
      _isLoading = false;
    });
  }

  /// Fungsi untuk beralih antara mode Login dan Register.
  void _switchAuthMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
      _errorMessage = null; // Hapus pesan error saat berganti mode.
      _formKey.currentState?.reset(); // Reset form.
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == AuthMode.login ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      // Gunakan SingleChildScrollView untuk menghindari overflow saat keyboard muncul.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Agar Card tidak memenuhi layar.
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tampilkan field 'Name' hanya pada mode Register.
                    if (_mode == AuthMode.register)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Please enter a valid email',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Password must be at least 6 characters',
                    ),
                    const SizedBox(height: 24),
                    // Tampilkan pesan error jika ada.
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Tampilkan tombol atau indikator loading.
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _submit,
                        child: Text(_mode == AuthMode.login ? 'Login' : 'Create Account'),
                      ),
                    TextButton(
                      onPressed: _switchAuthMode,
                      child: Text(_mode == AuthMode.login
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}