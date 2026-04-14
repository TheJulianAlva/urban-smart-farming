import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_event.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_state.dart';

/// Pantalla de Ajustes y Configuración (S-06)
/// Placeholder simple para el mockup inicial
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            context.go(AppRouter.login);
          }
        },
        child: ListView(
          children: [
            // Sección Cultivos
            _buildSectionHeader(context, 'Cultivos'),
            ListTile(
              leading: const Icon(Icons.grass),
              title: const Text('Ver mis Perfiles de Cultivo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lista de perfiles de cultivo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Añadir Nuevo Perfil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear nuevo perfil')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.device_hub),
              title: const Text('Asociar Dispositivos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asociar dispositivos')),
                );
              },
            ),

            const Divider(),

            // Sección Catálogo
            _buildSectionHeader(context, 'Catálogo'),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Gestión de Plantillas de Plantas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catálogo de plantas')),
                );
              },
            ),

            const Divider(),

            // Sección Cuenta
            _buildSectionHeader(context, 'Cuenta'),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Cambiar Contraseña'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cambiar contraseña')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            const Divider(),

            // Información de la app
            Padding(
              padding: const EdgeInsets.all(16),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
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
