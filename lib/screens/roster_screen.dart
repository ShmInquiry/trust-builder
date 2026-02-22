import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/network_node_model.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  List<NetworkNodeModel> _peers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPeers();
  }

  Future<void> _loadPeers() async {
    final nodes = await ApiService().getNetworkPeers();
    if (!mounted) return;
    setState(() {
      _peers = nodes.where((n) => n.id != 'you').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_peers.isEmpty) {
      return const Center(child: Text('No peers in your network yet', style: TextStyle(color: AppTheme.textMuted)));
    }

    return RefreshIndicator(
      onRefresh: _loadPeers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _peers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          final peer = _peers[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: index < _peers.length - 1
                  ? const Border(bottom: BorderSide(color: AppTheme.borderLight))
                  : null,
              borderRadius: index == 0
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : index == _peers.length - 1
                      ? const BorderRadius.vertical(bottom: Radius.circular(12))
                      : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ),
                  child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        peer.role,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                if (peer.trustLevel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _trustLevelColor(peer.trustLevel!).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      peer.trustLevel!,
                      style: TextStyle(
                        color: _trustLevelColor(peer.trustLevel!),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _trustLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return AppTheme.statusHealthy;
      case 'medium':
        return AppTheme.statusStalled;
      case 'low':
        return AppTheme.statusCritical;
      default:
        return AppTheme.textMuted;
    }
  }
}
