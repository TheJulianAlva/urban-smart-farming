import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/pages/auth_screen.dart';
import 'package:urban_smart_farming/features/main/main_nav_screen.dart';
import 'package:urban_smart_farming/features/main/crop_detail_screen.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_creation_wizard_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String login = '/login';
  static const String home = '/'; // Mi Jardín (dashboard global)
  static const String cropDetail = '/crops/:id';
  static const String createCrop = '/crops/create';
  static const String aiDiagnosis = '/ai-diagnosis'; // Placeholder

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
          return CropDetailScreen(cropId: cropId);
        },
      ),
      GoRoute(
        path: createCrop,
        name: 'createCrop',
        builder: (context, state) => const CropCreationWizardScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
