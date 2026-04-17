import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/pages/auth_screen.dart';
import 'package:urban_smart_farming/features/main/main_nav_screen.dart';
import 'package:urban_smart_farming/features/main/crop_detail_screen.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_creation_wizard_screen.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:urban_smart_farming/features/control/presentation/pages/control_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_profiles_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String login = '/login';
  static const String home = '/'; // Mi Jardín (dashboard global)
  static const String cropDetail = '/crops/:id';
  static const String createCrop = '/create-crop';
  static const String aiDiagnosis = '/ai-diagnosis'; // Placeholder
  static const String profiles = '/profiles';

  // Legacy routes - deprecated
  static const String crops = '/crops';
  static const String settings = '/settings';

  /// Router configuration
  static GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainNavScreen(),
      ),
      GoRoute(
        path: cropDetail,
        name: 'cropDetail',
        builder: (context, state) {
          final cropId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          final cropName = extra?['cropName'] as String? ?? 'Cultivo';
          return CropDetailScreen(cropId: cropId, cropName: cropName);
        },
      ),
      GoRoute(
        path: createCrop,
        name: 'createCrop',
        builder: (context, state) => const CropCreationWizardScreen(),
      ),
      GoRoute(
        path: '/dashboard/:id',
        name: 'dashboard',
        builder: (context, state) {
          final cropId = state.pathParameters['id']!;
          return DashboardScreen(cropId: cropId);
        },
      ),
      GoRoute(
        path: '/control/:id',
        name: 'control',
        builder: (context, state) {
          final cropId = state.pathParameters['id']!;
          return ControlScreen(cropId: cropId);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: profiles,
        name: 'profiles',
        builder: (context, state) => const CropProfilesScreen(),
      ),
    ],
  );
}
