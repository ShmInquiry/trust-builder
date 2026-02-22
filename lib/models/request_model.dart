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
