import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../widgets/request_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return MockData.coveyQuotes[dayOfYear % MockData.coveyQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final openCount = MockData.activeRequests.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Covey Primer',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${_getDailyQuote()}"',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stephen R. Covey',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Clarify Expectations'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Active Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$openCount open \u00b7 sorted by urgency',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...MockData.activeRequests.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: RequestCard(request: req),
            )),
      ],
    );
  }
}
