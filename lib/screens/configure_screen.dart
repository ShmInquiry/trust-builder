import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfigureScreen extends StatefulWidget {
  const ConfigureScreen({super.key});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  bool _profilePublic = true;
  bool _showTrustCounter = true;
  bool _syncContacts = false;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Configure'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              title: 'Make profile public',
              subtitle: 'Allow peers inside your organization to discover and message you.',
              value: _profilePublic,
              onChanged: (v) => setState(() => _profilePublic = v),
            ),
            _ToggleRow(
              title: 'Show Trust Counter',
              subtitle: 'Display your Emotional Bank balance on your profile header.',
              value: _showTrustCounter,
              onChanged: (v) => setState(() => _showTrustCounter = v),
            ),
            _ToggleRow(
              title: 'Sync phone contacts',
              subtitle: 'Suggest peers you frequently collaborate with.',
              value: _syncContacts,
              onChanged: (v) => setState(() => _syncContacts = v),
            ),
            const SizedBox(height: 28),
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              title: 'Dark mode',
              subtitle: 'Switch to a dark interface for low-light environments.',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _ToggleRow(
              title: 'Notifications',
              subtitle: 'Get alerts for stalled requests and new win-win agreements.',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved'), duration: Duration(seconds: 2)),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}
