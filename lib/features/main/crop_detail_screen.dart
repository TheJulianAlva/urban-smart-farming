import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:urban_smart_farming/features/control/presentation/pages/control_screen.dart';
import 'package:urban_smart_farming/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle de un cultivo con pestañas (Tabs)
/// Contiene 3 pestañas: Monitor, Control, Historial
class CropDetailScreen extends StatelessWidget {
  final String cropId;

  const CropDetailScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Cultivo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(AppRouter.settings),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Monitor'),
              Tab(icon: Icon(Icons.tune), text: 'Control'),
              Tab(icon: Icon(Icons.analytics), text: 'Historial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardScreen(cropId: cropId), // Pestaña Monitor
            ControlScreen(cropId: cropId), // Pestaña Control
            AnalyticsScreen(cropId: cropId), // Pestaña Historial
          ],
        ),
      ),
    );
  }
}
