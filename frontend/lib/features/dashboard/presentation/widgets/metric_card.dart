import 'package:flutter/material.dart';
import 'package:urban_smart_farming/core/theme/app_theme.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';

/// Widget reutilizable para mostrar métricas de sensores
class MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final SensorStatus status;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: statusColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(unit, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, SensorStatus status) {
    String text;
    switch (status) {
      case SensorStatus.optimal:
        text = 'Óptimo';
        break;
      case SensorStatus.warning:
        text = 'Precaución';
        break;
      case SensorStatus.danger:
        text = 'Peligro';
        break;
      case SensorStatus.offline:
        text = 'Offline';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(SensorStatus status) {
    switch (status) {
      case SensorStatus.optimal:
        return AppTheme.statusOptimal;
      case SensorStatus.warning:
        return AppTheme.statusWarning;
      case SensorStatus.danger:
        return AppTheme.statusDanger;
      case SensorStatus.offline:
        return Colors.grey;
    }
  }
}
