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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
        _currentUser.imagePath = pickedFile.path;
      });
      await DatabaseHelper.instance.updateUser(_currentUser);
    }
  }

  void _showFullImage() {
    if (_profileImageFile == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_profileImageFile!, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _editProfileDialog() {
    final nameController = TextEditingController(text: _currentUser.name);
    final emailController = TextEditingController(text: _currentUser.email);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password Baru (opsional)'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Ganti Foto'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              _currentUser.name = nameController.text.trim();
              _currentUser.email = emailController.text.trim();
              if (passwordController.text.isNotEmpty) {
                _currentUser.password = passwordController.text.trim();
              }
              await DatabaseHelper.instance.updateUser(_currentUser);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(colorScheme),
          const SizedBox(height: 20),
          _buildThemeCard(isDarkMode),
          const SizedBox(height: 20),
          _buildLogoutCard(colorScheme),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _profileImageFile != null ? _showFullImage : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _profileImageFile != null
                    ? Image.file(_profileImageFile!, width: 100, height: 100, fit: BoxFit.cover)
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentUser.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_currentUser.email, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profil',
              onPressed: _editProfileDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(bool isDarkMode) {
    final currentTheme = MyApp.of(context).appTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Tampilan & Tema:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildThemeOption('Blue', const Color(0xFF00BFFF), AppTheme.digital, currentTheme),
                SizedBox(width: 16),
                _buildThemeOption('Krem', const Color(0xFFF5DEB3), AppTheme.krem, currentTheme),
                SizedBox(width: 16),
                _buildThemeOption('Hijau', const Color(0xFF388E3C), AppTheme.forest, currentTheme),
                SizedBox(width: 16),
                _buildDarkModeToggle(isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.logout, color: colorScheme.onErrorContainer),
        title: Text(
          'Logout',
          style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
        ),
        onTap: () => MyApp.of(context).setAuthentication(false),
      ),
    );
  }

  Widget _buildThemeOption(String name, Color color, AppTheme theme, AppTheme selectedTheme) {
    final app = MyApp.of(context);
    final bool isSelected = theme == selectedTheme;

    return GestureDetector(
      onTap: () => app.setColorTheme(theme),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.9) : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade400),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(bool isDarkMode) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => MyApp.of(context).setTheme(!isDarkMode),
          child: Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
        ),
        const Text('Mode', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}