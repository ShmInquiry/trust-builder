import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailValid = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailValid = value.contains('@') && value.contains('.');
    });
  }

  void _createAccount() {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyEmailScreen(email: _emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to start building trust with your team.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Username', style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'alex.smith',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Email', style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: _onEmailChanged,
                decoration: InputDecoration(
                  hintText: 'you@company.com',
                  suffixIcon: _emailValid
                      ? const Icon(Icons.check, color: AppTheme.statusHealthy)
                      : null,
                ),
              ),
              if (_emailValid)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "Looks good. We'll send a confirmation link.",
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 20),
              const Text('Password', style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
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
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Use at least 8 characters, including a number.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _createAccount,
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By creating an account, you agree to the Terms and Data Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
