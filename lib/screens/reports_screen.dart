import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/trust_score_service.dart';
import '../services/request_service.dart';
import '../services/network_service.dart';
import '../models/request_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  int _trustScore = 0;
  String _healthStatus = 'Healthy';
  int _fairCount = 0;
  int _stalledCount = 0;
  int _criticalCount = 0;
  int _completedCount = 0;
  int _totalRequests = 0;
  int _networkSize = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final trustData = await TrustScoreService().getTrustScore();
      final requests = await RequestService().getRequests();
      final peers = await NetworkService().getNetworkPeers();

      int fair = 0, stalled = 0, critical = 0, completed = 0;
      for (final r in requests) {
        switch (r.status) {
          case RequestStatus.fair:
            fair++;
            break;
          case RequestStatus.stalled:
            stalled++;
            break;
          case RequestStatus.critical:
            critical++;
            break;
        }
      }

      setState(() {
        _trustScore = trustData?.score ?? 0;
        _healthStatus = trustData?.status ?? 'Healthy';
        _fairCount = fair;
        _stalledCount = stalled;
        _criticalCount = critical;
        _completedCount = completed;
        _totalRequests = requests.length;
        _networkSize = peers.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reports'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrustScoreCard(),
                    const SizedBox(height: 20),
                    const Text(
                      'Request Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow('Fair', _fairCount, AppTheme.statusFair),
                    _buildStatusRow('Stalled', _stalledCount, AppTheme.statusStalled),
                    _buildStatusRow('Critical', _criticalCount, AppTheme.statusCritical),
                    _buildStatusRow('Completed', _completedCount, AppTheme.statusHealthy),
                    const Divider(height: 24),
                    _buildStatusRow('Total Requests', _totalRequests, AppTheme.textDark),
                    const SizedBox(height: 24),
                    const Text(
                      'Network',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.people_outline,
                      label: 'Connected Peers',
                      value: '$_networkSize',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTrustScoreCard() {
    Color healthColor;
    switch (_healthStatus.toLowerCase()) {
      case 'critical':
        healthColor = AppTheme.statusCritical;
        break;
      case 'stalled':
      case 'at risk':
        healthColor = AppTheme.statusStalled;
        break;
      default:
        healthColor = AppTheme.statusHealthy;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Text(
            'Trust Score',
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            '$_trustScore',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'EB Points',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: healthColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _healthStatus,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: healthColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
