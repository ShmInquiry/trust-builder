import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/network_service.dart';
import '../models/network_node_model.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  String? _selectedNodeId;
  final TransformationController _transformController = TransformationController();
  List<NetworkNodeModel> _nodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final nodes = await NetworkService().getNetworkPeers();
    if (mounted) {
      setState(() {
        _nodes = nodes;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _recenter() {
    _transformController.value = Matrix4.identity();
    setState(() => _selectedNodeId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nodes.isEmpty) {
      return const Center(child: Text('No network peers yet', style: TextStyle(color: AppTheme.textMuted)));
    }

    final selectedNode = _selectedNodeId != null
        ? _nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => _nodes.first)
        : null;

    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformController,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2.5,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: _NetworkPainter(
                    nodes: _nodes,
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                  child: Stack(
                    children: _nodes.map((node) {
                      final x = node.x * constraints.maxWidth;
                      final y = node.y * constraints.maxHeight;
                      final isYou = node.id == 'you';
                      final isSelected = node.id == _selectedNodeId;
                      final size = isYou ? 64.0 : 48.0;

                      return Positioned(
                        left: x - size / 2,
                        top: y - size / 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedNodeId = node.id == _selectedNodeId ? null : node.id;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isYou
                                      ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                                      : AppTheme.backgroundGrey,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : isYou
                                            ? AppTheme.primaryBlue
                                            : AppTheme.borderLight,
                                    width: isSelected ? 2.5 : isYou ? 2 : 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: isYou ? AppTheme.primaryBlue : AppTheme.textMuted,
                                    size: isYou ? 28 : 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                node.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isYou ? FontWeight.w600 : FontWeight.w500,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              if (node.role.isNotEmpty && !isYou)
                                Text(
                                  node.role,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        if (selectedNode != null && selectedNode.trustLevel != null)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedNode.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    selectedNode.role,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.statusHealthy.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedNode.trustLevel!,
                      style: const TextStyle(
                        color: AppTheme.statusHealthy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MapButton(
                icon: Icons.add,
                onTap: () {
                  final current = _transformController.value.clone();
                  current.scale(1.2);
                  _transformController.value = current;
                },
              ),
              const SizedBox(width: 8),
              _MapButton(
                icon: Icons.remove,
                onTap: () {
                  final current = _transformController.value.clone();
                  current.scale(0.8);
                  _transformController.value = current;
                },
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _recenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Recenter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textDark),
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final List<NetworkNodeModel> nodes;
  final Size size;

  _NetworkPainter({required this.nodes, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = AppTheme.borderLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final youIdx = nodes.indexWhere((n) => n.id == 'you');
    if (youIdx == -1) return;
    final youNode = nodes[youIdx];
    final youPos = Offset(youNode.x * size.width, youNode.y * size.height);

    for (final node in nodes) {
      if (node.id == 'you') continue;
      final pos = Offset(node.x * size.width, node.y * size.height);
      canvas.drawLine(youPos, pos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
