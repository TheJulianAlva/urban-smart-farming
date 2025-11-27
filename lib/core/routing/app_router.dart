import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/pages/auth_screen.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_list_screen.dart';
import 'package:urban_smart_farming/features/main/crop_detail_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String login = '/login';
  static const String crops = '/crops';
  static const String cropDetail = '/crops/:id';
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
        path: crops,
        name: 'crops',
        builder: (context, state) => const CropListScreen(),
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
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
