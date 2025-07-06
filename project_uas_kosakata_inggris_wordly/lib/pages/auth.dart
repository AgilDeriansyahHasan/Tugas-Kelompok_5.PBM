import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../main.dart';
import '../models/user.dart';

enum AuthMode { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _mode = AuthMode.login;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final db = DatabaseHelper.instance;

    try {
      if (_mode == AuthMode.register) {
        final newUser = User(
          userId: DateTime.now().millisecondsSinceEpoch,
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text.trim(),
        );

        await db.insertUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        _switchAuthMode();
      } else {
        final user = await db.authenticate(
          _emailController.text.trim().toLowerCase(),
          _passwordController.text.trim(),
        );

        if (user == null) {
          setState(() => _errorMessage = 'Invalid email or password.');
        } else {
          MyApp.of(context).setAuthentication(true, user: user);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred: ${e.toString()}');
    }

    setState(() => _isLoading = false);
  }

  void _switchAuthMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
      _errorMessage = null;
      _formKey.currentState?.reset();
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
    final isLogin = _mode == AuthMode.login;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLogin ? Icons.account_circle : Icons.person_add,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    if (!isLogin)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                      ),

                    if (!isLogin) const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                      value != null && value.contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) =>
                      value != null && value.length >= 6 ? null : 'Minimum 6 characters',
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _switchAuthMode,
                      child: Text(
                        isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login',
                        style: const TextStyle(fontSize: 14),
                      ),
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
