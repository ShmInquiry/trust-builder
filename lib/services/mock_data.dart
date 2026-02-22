import '../models/request_model.dart';
import '../models/alert_model.dart';
import '../models/network_node_model.dart';

class MockData {
  static const List<String> coveyQuotes = [
    "Trust is the glue of life. It's the most essential ingredient in effective communication.",
    "Most people do not listen with the intent to understand; they listen with the intent to reply.",
    "Strength lies in differences, not in similarities.",
    "The key is not to prioritize what's on your schedule, but to schedule your priorities.",
    "Begin with the end in mind.",
    "Seek first to understand, then to be understood.",
    "Synergy is better than my way or your way. It's our way.",
  ];

  static const int trustScore = 320;
  static const String trustStatus = 'Healthy';

  static const List<RequestModel> activeRequests = [
    RequestModel(
      id: '1',
      title: 'Marketing budget breakdown',
      description: 'Clarify spend expectations for Q3 launch assets so Finance and Marketing stay aligned.',
      status: RequestStatus.fair,
      stalledDays: 0,
      peers: ['Finance', 'Marketing'],
      documentId: 'DOC-2024-042',
    ),
    RequestModel(
      id: '2',
      title: 'Sales forecast alignment',
      description: "Update on regional targets and ownership before Friday's executive review.",
      status: RequestStatus.stalled,
      stalledDays: 3,
      peers: ['Sales', 'Operations'],
      documentId: 'DOC-2024-039',
    ),
    RequestModel(
      id: '3',
      title: 'Platform maintenance window',
      description: 'Confirm approved downtime and communications so customer-facing teams can prepare.',
      status: RequestStatus.critical,
      stalledDays: 5,
      peers: ['Engineering', 'Support'],
      documentId: 'DOC-2024-037',
    ),
  ];

  static const List<AlertModel> alerts = [
    AlertModel(
      id: '1',
      title: 'Stalled request: Marketing Budget Allocation',
      description: 'Your expectation to confirm Q3 budget has been waiting for a response.',
      type: AlertType.stalled,
      timeAgo: '3d ago',
      badgeLabel: 'Stalled \u00b7 3 days',
      actionLabel: 'Talk Straight',
    ),
    AlertModel(
      id: '2',
      title: 'Win-Win agreement approved',
      description: 'Emma Clark accepted the performance agreement for Product Launch Readiness.',
      type: AlertType.winWin,
      timeAgo: '2h ago',
      badgeLabel: 'Win-Win \u00b7 EB +40',
      actionLabel: 'View agreement',
    ),
    AlertModel(
      id: '3',
      title: 'Clarify expectations with Sales',
      description: "Based on last week's interactions, 3 peers are waiting for clearer handoffs.",
      type: AlertType.suggestion,
      timeAgo: 'Today \u00b7 9:15',
      badgeLabel: 'Suggestion',
      actionLabel: 'Start request',
    ),
    AlertModel(
      id: '4',
      title: 'Critical: Platform maintenance window',
      description: 'Downtime plan is overdue. Reach out to Kenji to reset expectations.',
      type: AlertType.critical,
      timeAgo: '5d ago',
      badgeLabel: 'Critical \u00b7 5+ days',
      actionLabel: 'Open request',
    ),
  ];

  static const List<NetworkNodeModel> networkNodes = [
    NetworkNodeModel(id: 'you', name: 'You', role: '', x: 0.5, y: 0.45),
    NetworkNodeModel(id: '1', name: 'Alex', role: 'Engineering', x: 0.3, y: 0.2),
    NetworkNodeModel(id: '2', name: 'Priya', role: 'Operations Lead', trustLevel: 'High Trust', x: 0.7, y: 0.2),
    NetworkNodeModel(id: '3', name: 'Kenji', role: 'Product', x: 0.25, y: 0.7),
    NetworkNodeModel(id: '4', name: 'Lena', role: 'Design', x: 0.75, y: 0.7),
    NetworkNodeModel(id: '5', name: 'Maria', role: 'HR', x: 0.15, y: 0.45),
  ];
}
