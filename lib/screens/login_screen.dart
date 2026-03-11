////
/// FEATURE IMPLEMENTATION: Login
/// This file is responsible for the user login implementation.
/// It authenticates users by connecting to the backend via the AuthService and sets the local session token.
////
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username is required';
    }
    final text = value.trim();
    if (text.contains('@')) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(text)) {
        return 'Please enter a valid email address';
      }
    } else {
      if (text.length < 3) {
        return 'Username must be at least 3 characters';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final result = await AuthService().login(email, password);

      if (mounted) {
        if (result.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result.error ?? 'Invalid email or password. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'TO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your Trust OS account.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.statusCritical.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.statusCritical, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.statusCritical, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text('Email or Username', style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  validator: _validateIdentifier,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: 'Email or username',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Password', style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.lock_outline : Icons.lock_open,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Demo: demo@trustos.app / demo1234',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: AppTheme.borderLight)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or continue with', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ),
                    Expanded(child: Container(height: 1, color: AppTheme.borderLight)),
                  ],
                ),
                const SizedBox(height: 24),
                Tooltip(
                  message: 'Coming soon',
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(26),
                      color: AppTheme.backgroundGrey.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, color: AppTheme.textMuted, size: 28),
                        const SizedBox(width: 8),
                        const Text('Sign in with Google', style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Tooltip(
                  message: 'Coming soon',
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(26),
                      color: AppTheme.backgroundGrey.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.window, color: AppTheme.textMuted, size: 20),
                        const SizedBox(width: 12),
                        const Text('Sign in with Microsoft', style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Create one',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
