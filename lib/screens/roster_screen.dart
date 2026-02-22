import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peers = MockData.networkNodes.where((n) => n.id != 'you').toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: peers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final peer = peers[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: index < peers.length - 1
                ? const Border(bottom: BorderSide(color: AppTheme.borderLight))
                : null,
            borderRadius: index == 0
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : index == peers.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      peer.role,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              if (peer.trustLevel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.statusHealthy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    peer.trustLevel!,
                    style: const TextStyle(
                      color: AppTheme.statusHealthy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
            ],
          ),
        );
      },
    );
  }
}
