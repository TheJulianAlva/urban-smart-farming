import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:urban_smart_farming/features/control/presentation/pages/control_screen.dart';
import 'package:urban_smart_farming/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/pages/ai_diagnosis_screen.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_bloc.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle de un cultivo con pestañas (Tabs)
/// Contiene 4 pestañas: Monitor, Control, Historial, Diagnóstico IA
class CropDetailScreen extends StatelessWidget {
  final String cropId;
  final String cropName;
  final PlantProfile? cropProfile;

  const CropDetailScreen({
    required this.cropId,
    this.cropName = 'Cultivo',
    this.cropProfile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(cropName),
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
              Tab(icon: Icon(Icons.document_scanner), text: 'Diagnóstico'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardScreen(cropId: cropId, cropProfile: cropProfile),
            ControlScreen(cropId: cropId),
            AnalyticsScreen(cropId: cropId),
            BlocProvider(
              create: (_) => getIt<AiDiagnosisBloc>(param1: cropId),
              child: AiDiagnosisScreen(cropId: cropId, cropName: cropName),
            ),
          ],
        ),
      ),
    );
  }
}
