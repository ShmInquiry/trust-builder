import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../models/request_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enabled = true;
  bool _fairEnabled = false;
  bool _stalledEnabled = true;
  bool _criticalEnabled = true;
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;
  List<RequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final service = NotificationService();
    final enabled = await service.isEnabled;
    final hour = await service.scheduledHour;
    final minute = await service.scheduledMinute;
    final filters = await service.getTaskFilters();
    final requests = await ApiService().getRequests();

    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _scheduledTime = TimeOfDay(hour: hour, minute: minute);
      _fairEnabled = filters['fair'] ?? false;
      _stalledEnabled = filters['stalled'] ?? true;
      _criticalEnabled = filters['critical'] ?? true;
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<void> _saveFilters() async {
    await NotificationService().setTaskFilter(
      fair: _fairEnabled,
      stalled: _stalledEnabled,
      critical: _criticalEnabled,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null && mounted) {
      setState(() => _scheduledTime = picked);
      await NotificationService().setScheduledTime(picked.hour, picked.minute);
    }
  }

  Future<void> _testNotification() async {
    final service = NotificationService();

    final selectedTypes = <String>[];
    if (_fairEnabled) selectedTypes.add('Fair');
    if (_stalledEnabled) selectedTypes.add('Stalled');
    if (_criticalEnabled) selectedTypes.add('Critical');

    final typeStr = selectedTypes.isEmpty ? 'all' : selectedTypes.join(', ');

    await service.showNotification(
      title: 'Trust OS Reminder',
      body: 'You have active requests ($typeStr). Review them to maintain your trust score!',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _getRequestCount(RequestStatus status) {
    return _requests.where((r) => r.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnableSection(),
                  const SizedBox(height: 24),
                  _buildTaskSelectionSection(),
                  const SizedBox(height: 24),
                  _buildTimeSection(),
                  const SizedBox(height: 24),
                  _buildTestSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildEnableSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _enabled
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _enabled ? Icons.notifications_active : Icons.notifications_off,
              color: _enabled ? AppTheme.primaryBlue : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _enabled ? 'Notifications are enabled' : 'Notifications are disabled',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            activeColor: AppTheme.primaryBlue,
            onChanged: (value) async {
              setState(() => _enabled = value);
              await NotificationService().setEnabled(value);
              if (!value) {
                await NotificationService().cancelAll();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelectionSection() {
    return AnimatedOpacity(
      opacity: _enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose which request types trigger notifications',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            _buildTaskCheckbox(
              label: 'Critical Requests',
              subtitle: '${_getRequestCount(RequestStatus.critical)} active',
              value: _criticalEnabled,
              color: AppTheme.statusCritical,
              icon: Icons.error_outline,
              onChanged: (v) {
                setState(() => _criticalEnabled = v ?? true);
                _saveFilters();
              },
            ),
            _buildTaskCheckbox(
              label: 'Stalled Requests',
              subtitle: '${_getRequestCount(RequestStatus.stalled)} active',
              value: _stalledEnabled,
              color: AppTheme.statusStalled,
              icon: Icons.warning_amber_rounded,
              onChanged: (v) {
                setState(() => _stalledEnabled = v ?? true);
                _saveFilters();
              },
            ),
            _buildTaskCheckbox(
              label: 'Fair Requests',
              subtitle: '${_getRequestCount(RequestStatus.fair)} active',
              value: _fairEnabled,
              color: AppTheme.statusHealthy,
              icon: Icons.check_circle_outline,
              onChanged: (v) {
                setState(() => _fairEnabled = v ?? false);
                _saveFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCheckbox({
    required String label,
    required String subtitle,
    required bool value,
    required Color color,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? color.withValues(alpha: 0.4) : AppTheme.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTimeSection() {
    final formattedTime = _scheduledTime.format(context);

    return AnimatedOpacity(
      opacity: _enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Set a daily time to receive task reminders',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Reminder',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return AnimatedOpacity(
      opacity: _enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Send a test notification to verify your setup',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.send, size: 20),
                label: const Text(
                  'Send Test Notification',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
