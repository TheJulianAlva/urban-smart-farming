import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/pages/auth_screen.dart';
import 'package:urban_smart_farming/features/main/main_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String login = '/login';
  static const String main = '/main';
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
        path: main,
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
