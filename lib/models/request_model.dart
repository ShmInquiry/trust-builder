enum RequestStatus { fair, stalled, critical }

class RequestModel {
  final String id;
  final String title;
  final String description;
  final RequestStatus status;
  final int stalledDays;
  final List<String> peers;
  final String? documentId;

  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.stalledDays = 0,
    this.peers = const [],
    this.documentId,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    RequestStatus parseStatus(String s) {
      switch (s.toLowerCase()) {
        case 'critical':
          return RequestStatus.critical;
        case 'stalled':
          return RequestStatus.stalled;
        default:
          return RequestStatus.fair;
      }
    }

    return RequestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: parseStatus(json['status'] as String? ?? 'fair'),
      stalledDays: json['stalled_days'] as int? ?? 0,
      peers: (json['peers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      documentId: json['document_id'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case RequestStatus.fair:
        return 'Fair';
      case RequestStatus.stalled:
        return 'Stalled';
      case RequestStatus.critical:
        return 'Critical';
    }
  }

  String get statusDetail {
    switch (status) {
      case RequestStatus.fair:
        return 'On track';
      case RequestStatus.stalled:
        return 'Stalled \u00b7 $stalledDays days';
      case RequestStatus.critical:
        return 'Critical \u00b7 $stalledDays days';
    }
  }
}
