import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initialize();
  runApp(const TrustOSApp());
}

class TrustOSApp extends StatefulWidget {
  const TrustOSApp({super.key});

  @override
  State<TrustOSApp> createState() => _TrustOSAppState();
}

class _TrustOSAppState extends State<TrustOSApp> {
  Widget? _home;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final restored = await AuthService().restoreSession();
    setState(() {
      _home = restored ? const MainShell() : const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trust OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _home ?? Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'TO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Color(0xFF2563EB)),
            ],
          ),
        ),
      ),
    );
  }
}
