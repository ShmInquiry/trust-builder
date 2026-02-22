import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'network_screen.dart';
import 'roster_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _trustScore = 0;
  String _trustStatus = '...';

  static const _titles = ['Trust\nDashboard', 'Network Map', 'Roster', 'Alerts'];

  final List<Widget> _screens = const [
    HomeScreen(),
    NetworkScreen(),
    RosterScreen(),
    AlertsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTrustScore();
  }

  Future<void> _loadTrustScore() async {
    final result = await ApiService().getTrustScore();
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _trustScore = result.score;
        _trustStatus = result.status;
      });
    }
  }

  Color get _trustStatusColor {
    switch (_trustStatus.toLowerCase()) {
      case 'healthy':
        return AppTheme.statusHealthy;
      case 'fair':
        return AppTheme.statusStalled;
      case 'critical':
        return AppTheme.statusCritical;
      default:
        return AppTheme.textMuted;
    }
  }

  void _logout() {
    ApiService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/trust_os_logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('TO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _titles[0],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _trustStatusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'EB: $_trustScore \u00b7 $_trustStatus',
                style: TextStyle(
                  color: _trustStatusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      case 1:
        return AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(_titles[1]),
          actions: [
            Container(
              width: 180,
              height: 36,
              margin: const EdgeInsets.only(right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search network',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: AppTheme.backgroundGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      case 2:
        return AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(_titles[2]),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        );
      case 3:
        return AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(_titles[3]),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, size: 22),
              onPressed: () {},
            ),
          ],
        );
      default:
        return AppBar(title: Text(_titles[0]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: _buildAppBar(),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'TO',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Trust OS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ApiService().username ?? 'Build trust, one interaction at a time.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () {
                  setState(() => _currentIndex = 0);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.share_outlined,
                label: 'Network',
                onTap: () {
                  setState(() => _currentIndex = 1);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.list_alt,
                label: 'Roster',
                onTap: () {
                  setState(() => _currentIndex = 2);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                onTap: () {
                  setState(() => _currentIndex = 3);
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'Profile & Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              _DrawerItem(
                icon: Icons.logout,
                label: 'Sign Out',
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Trust OS v1.0.0',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.share_outlined), activeIcon: Icon(Icons.share), label: 'Network'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Roster'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textDark, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textDark),
      ),
      onTap: onTap,
    );
  }
}
