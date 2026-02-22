import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/alert_model.dart';
import '../services/mock_data.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'All';

  List<AlertModel> get _filteredAlerts {
    if (_selectedFilter == 'All') return MockData.alerts;
    if (_selectedFilter == 'Requests') {
      return MockData.alerts
          .where((a) => a.type != AlertType.system)
          .toList();
    }
    return MockData.alerts
        .where((a) => a.type == AlertType.system)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Stay ahead of stalled requests, new agreements, and trust signals.',
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['All', 'Requests', 'System'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.textDark : AppTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredAlerts.length,
            itemBuilder: (context, index) {
              return _AlertCard(alert: _filteredAlerts[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  const _AlertCard({required this.alert});

  IconData get _icon {
    switch (alert.type) {
      case AlertType.stalled:
        return Icons.warning_amber_rounded;
      case AlertType.winWin:
        return Icons.handshake_outlined;
      case AlertType.suggestion:
        return Icons.lightbulb_outline;
      case AlertType.critical:
        return Icons.error_outline;
      case AlertType.system:
        return Icons.info_outline;
    }
  }

  Color get _iconColor {
    switch (alert.type) {
      case AlertType.stalled:
        return AppTheme.statusStalled;
      case AlertType.winWin:
        return AppTheme.primaryBlue;
      case AlertType.suggestion:
        return AppTheme.primaryBlue;
      case AlertType.critical:
        return AppTheme.statusCritical;
      case AlertType.system:
        return AppTheme.textMuted;
    }
  }

  Color get _badgeColor {
    switch (alert.type) {
      case AlertType.stalled:
        return AppTheme.statusStalled;
      case AlertType.winWin:
        return AppTheme.statusHealthy;
      case AlertType.suggestion:
        return AppTheme.primaryBlue;
      case AlertType.critical:
        return AppTheme.statusCritical;
      case AlertType.system:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      alert.timeAgo,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    if (alert.badgeLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alert.badgeLabel!,
                          style: TextStyle(
                            color: _badgeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (alert.actionLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          alert.actionLabel!,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
