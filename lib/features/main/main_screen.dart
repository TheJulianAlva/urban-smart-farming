import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:urban_smart_farming/features/control/presentation/pages/control_screen.dart';
import 'package:urban_smart_farming/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:urban_smart_farming/features/alerts/presentation/pages/alerts_screen.dart';

/// Scaffold principal con BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ControlScreen(),
    AnalyticsScreen(),
    AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Control'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}
