class NetworkNodeModel {
  final String id;
  final String name;
  final String role;
  final String? trustLevel;
  final double x;
  final double y;

  const NetworkNodeModel({
    required this.id,
    required this.name,
    required this.role,
    this.trustLevel,
    required this.x,
    required this.y,
  });
}
