import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/sensor_gauge.dart';

/// Widget compacto para mostrar un sensor en una tarjeta pequeña
class SensorMiniCard extends StatelessWidget {
  final Sensor? sensor;
  final SensorStatus status;

  const SensorMiniCard({
    super.key,
    required this.sensor,
    this.status = SensorStatus.unknown,
  });

  @override
  Widget build(BuildContext context) {
    if (sensor == null) {
      return const SizedBox.shrink();
    }

    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSensorIcon(), color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            sensor!.currentValue?.toStringAsFixed(1) ?? '--',
            textScaler: MediaQuery.textScalerOf(
              context,
            ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.3),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            sensor!.unit,
            textScaler: MediaQuery.textScalerOf(
              context,
            ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.3),
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SensorStatus status) {
    switch (status) {
      case SensorStatus.optimal:
        return Colors.green[600]!;
      case SensorStatus.warning:
        return Colors.orange[600]!;
      case SensorStatus.critical:
        return Colors.red[600]!;
      case SensorStatus.unknown:
        return Colors.grey[400]!;
    }
  }

  IconData _getSensorIcon() {
    switch (sensor!.type) {
      case SensorType.temperature:
        return Icons.thermostat;
      case SensorType.soilMoisture:
        return Icons.water_drop;
      case SensorType.ph:
        return Icons.science;
      case SensorType.light:
        return Icons.wb_sunny;
    }
  }
}
