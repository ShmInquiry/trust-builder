import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  const RequestCard({super.key, required this.request});

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.fair:
        return AppTheme.statusFair;
      case RequestStatus.stalled:
        return AppTheme.statusStalled;
      case RequestStatus.critical:
        return AppTheme.statusCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status: ${request.statusLabel} \u00b7 ${request.statusDetail}',
                  style: TextStyle(
                    fontSize: 13,
                    color: request.status == RequestStatus.fair
                        ? AppTheme.textMuted
                        : _statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
