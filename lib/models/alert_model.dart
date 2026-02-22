enum AlertType { stalled, winWin, suggestion, critical, system }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final String timeAgo;
  final String? badgeLabel;
  final String? actionLabel;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timeAgo,
    this.badgeLabel,
    this.actionLabel,
    this.isRead = false,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    AlertType parseType(String s) {
      switch (s.toLowerCase()) {
        case 'request':
          return AlertType.stalled;
        case 'system':
          return AlertType.system;
        default:
          return AlertType.system;
      }
    }

    String computeTimeAgo(String? createdAt) {
      if (createdAt == null) return '';
      try {
        final dt = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(dt);
        if (diff.inDays > 0) return '${diff.inDays}d ago';
        if (diff.inHours > 0) return '${diff.inHours}h ago';
        if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
        return 'Just now';
      } catch (_) {
        return '';
      }
    }

    final alertType = parseType(json['alert_type'] as String? ?? 'system');
    final title = json['title'] as String? ?? '';

    String? badge;
    if (title.toLowerCase().contains('critical')) {
      badge = 'Critical';
    } else if (title.toLowerCase().contains('stalled')) {
      badge = 'Stalled';
    }

    return AlertModel(
      id: json['id'] as String,
      title: title,
      description: json['message'] as String? ?? '',
      type: alertType,
      timeAgo: computeTimeAgo(json['created_at'] as String?),
      badgeLabel: badge,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
