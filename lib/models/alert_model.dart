enum AlertType { stalled, winWin, suggestion, critical, system }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final String timeAgo;
  final String? badgeLabel;
  final String? actionLabel;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timeAgo,
    this.badgeLabel,
    this.actionLabel,
  });
}
