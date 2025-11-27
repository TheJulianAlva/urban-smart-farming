import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:urban_smart_farming/features/control/presentation/pages/control_screen.dart';
import 'package:urban_smart_farming/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:urban_smart_farming/features/alerts/presentation/pages/alerts_screen.dart';

/// Scaffold principal con BottomNavigationBar para un cultivo específico
class CropDetailScreen extends StatefulWidget {
  final String cropId;

  const CropDetailScreen({required this.cropId, super.key});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Screens receive cropId
    final List<Widget> screens = [
      DashboardScreen(cropId: widget.cropId),
      ControlScreen(cropId: widget.cropId),
      AnalyticsScreen(cropId: widget.cropId),
      const AlertsScreen(), // Global alerts
    ];

    return Scaffold(
      body: screens[_currentIndex],
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
