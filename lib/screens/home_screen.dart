import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';
import '../models/request_model.dart';
import '../widgets/request_card.dart';
import 'create_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final requests = await ApiService().getRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<void> _openCreateRequest() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
    );
    if (result == true) {
      _loadRequests();
    }
  }

  String _getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return MockData.coveyQuotes[dayOfYear % MockData.coveyQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateRequest,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
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
              onPressed: _openCreateRequest,
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
                '${_requests.length} open \u00b7 sorted by urgency',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else if (_requests.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No active requests', style: TextStyle(color: AppTheme.textMuted)),
            ))
          else
            ..._requests.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: RequestCard(request: req),
                )),
          ],
        ),
      ),
    );
  }
}
