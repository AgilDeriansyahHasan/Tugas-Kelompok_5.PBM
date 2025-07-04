// pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../main.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State lokal untuk user, agar bisa diubah setelah editan.
  late User _currentUser;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    if (_currentUser.imagePath != null) {
      _profileImageFile = File(_currentUser.imagePath!);
    }
  }

  /// Fungsi untuk memilih gambar dari galeri.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
      _currentUser.imagePath = pickedFile.path;
      // Simpan perubahan ke database.
      await DatabaseHelper.instance.updateUser(_currentUser);
    }
  }

  /// Menampilkan dialog untuk mengedit informasi profil.
  void _editProfileDialog() {
    final nameController = TextEditingController(text: _currentUser.name);
    final emailController = TextEditingController(text: _currentUser.email);
    // Password tidak ditampilkan, hanya untuk input baru.
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'New Password (optional)'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              _currentUser.name = nameController.text.trim();
              _currentUser.email = emailController.text.trim();
              // Hanya update password jika field diisi.
              if (passwordController.text.isNotEmpty) {
                _currentUser.password = passwordController.text.trim();
              }
              await DatabaseHelper.instance.updateUser(_currentUser);
              Navigator.pop(ctx);
              // Perbarui UI dengan data baru.
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : null,
                    child: _profileImageFile == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser.email,
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _editProfileDialog,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
        const SizedBox(height: 20),
        Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              // Panggil fungsi global untuk mengubah tema.
              MyApp.of(context).setTheme(value);
            },
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: colorScheme.errorContainer,
          child: ListTile(
            leading: Icon(Icons.logout, color: colorScheme.onErrorContainer),
            title: Text('Logout', style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
            onTap: () {
              // Panggil fungsi global untuk logout.
              MyApp.of(context).setAuthentication(false);
            },
          ),
        ),
      ],
    );
  }
}