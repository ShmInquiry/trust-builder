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

  factory NetworkNodeModel.fromJson(Map<String, dynamic> json) {
    return NetworkNodeModel(
      id: json['id'] as String,
      name: json['peer_name'] as String? ?? '',
      role: '${json['interactions'] ?? 0} interactions',
      trustLevel: json['trust_level'] as String?,
      x: (json['position_x'] as num?)?.toDouble() ?? 0.0,
      y: (json['position_y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
