import 'package:flutter/material.dart';

/// Widget que muestra el estado global de todos los cultivos
class GlobalStatusCard extends StatelessWidget {
  final int totalCrops;
  final int cropsNeedingAttention;
  final int criticalCrops;

  const GlobalStatusCard({
    super.key,
    required this.totalCrops,
    required this.cropsNeedingAttention,
    required this.criticalCrops,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el estado global
    final GlobalStatus status = _calculateGlobalStatus();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: status.color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(status.icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Contador de cultivos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalCrops',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GlobalStatus _calculateGlobalStatus() {
    if (totalCrops == 0) {
      return GlobalStatus(
        color: Colors.grey[400]!,
        icon: Icons.eco_outlined,
        title: 'Sin cultivos',
        subtitle: 'Crea tu primer cultivo para comenzar',
      );
    }

    if (criticalCrops > 0) {
      return GlobalStatus(
        color: Colors.red[600]!,
        icon: Icons.error,
        title: '¡Atención urgente!',
        subtitle:
            '$criticalCrops ${criticalCrops == 1 ? 'cultivo requiere' : 'cultivos requieren'} acción inmediata',
      );
    }

    if (cropsNeedingAttention > 0) {
      return GlobalStatus(
        color: Colors.orange[600]!,
        icon: Icons.warning,
        title: 'Requiere atención',
        subtitle:
            '$cropsNeedingAttention ${cropsNeedingAttention == 1 ? 'cultivo necesita' : 'cultivos necesitan'} cuidado',
      );
    }

    return GlobalStatus(
      color: Colors.green[600]!,
      icon: Icons.check_circle,
      title: '¡Tus cultivos están excelentes!',
      subtitle: 'Todos los cultivos en condiciones óptimas',
    );
  }
}

/// Clase auxiliar para el estado global
class GlobalStatus {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  GlobalStatus({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
