import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_event.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_state.dart';

/// Pantalla de Ajustes
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            context.go(AppRouter.login);
          }
        },
        child: ListView(
          children: [
            // Sección Perfiles de Cultivo
            _buildSectionHeader(context, 'Perfiles de Cultivo', Icons.eco),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Ver Perfiles'),
              subtitle: const Text('Catálogo y tus perfiles personalizados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRouter.profiles),
            ),

            const Divider(),

            // Sección Cuenta
            _buildSectionHeader(context, 'Cuenta', Icons.person),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showLogoutDialog(context),
            ),

            const Divider(),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Text(
                  'Urban Smart Farming v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
