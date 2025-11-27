import 'package:flutter/material.dart';
import 'package:urban_smart_farming/core/theme/app_theme.dart';

/// Pantalla de Alertas y Diagnóstico (S-05)
/// Placeholder simple para el mockup inicial
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alertas y Diagnóstico'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notificaciones', icon: Icon(Icons.notifications)),
              Tab(text: 'Diagnóstico IA', icon: Icon(Icons.camera_alt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Notificaciones
            _buildNotificationsTab(context),

            // Pestaña de Diagnóstico (no implementado en mockup)
            _buildDiagnosisTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(BuildContext context) {
    final alerts = [
      {
        'title': 'Humedad crítica',
        'message': 'La humedad ha bajado a 18% en "Tomates"',
        'severity': 'high',
        'time': 'Hace 2 horas',
      },
      {
        'title': 'Temperatura elevada',
        'message': 'Temperatura alcanzó 32°C',
        'severity': 'medium',
        'time': 'Hace 5 horas',
      },
      {
        'title': 'Riego completado',
        'message': 'Ciclo de riego finalizado exitosamente',
        'severity': 'low',
        'time': 'Hace 1 día',
      },
      {
        'title': 'Sensor offline',
        'message': 'Sensor de pH no responde',
        'severity': 'high',
        'time': 'Hace 2 días',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSeverityColor(
                alert['severity'] as String,
              ).withValues(alpha: 0.2),
              child: Icon(
                _getSeverityIcon(alert['severity'] as String),
                color: _getSeverityColor(alert['severity'] as String),
              ),
            ),
            title: Text(alert['title'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(alert['message'] as String),
                const SizedBox(height: 4),
                Text(
                  alert['time'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildDiagnosisTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Diagnóstico con IA',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionalidad de análisis de imágenes con Visión por Computadora disponible en la versión completa de la aplicación.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: null, // Deshabilitado en mockup
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null, // Deshabilitado en mockup
              icon: const Icon(Icons.photo_library),
              label: const Text('Subir Imagen'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppTheme.statusDanger;
      case 'medium':
        return AppTheme.statusWarning;
      case 'low':
        return AppTheme.statusOptimal;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'high':
        return Icons.error;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
