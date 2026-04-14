import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/sensor_gauge.dart';

/// Widget compacto que muestra indicadores de estado de sensores
class SensorStatusIndicators extends StatelessWidget {
  final CropEntity crop;
  final bool compact;

  const SensorStatusIndicators({
    super.key,
    required this.crop,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!crop.hasHardware) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniIndicator(
          context,
          crop.getSensor(SensorType.temperature),
          crop.profile.isTemperatureOptimal,
        ),
        const SizedBox(width: 8),
        _buildMiniIndicator(
          context,
          crop.getSensor(SensorType.soilMoisture),
          crop.profile.isSoilMoistureOptimal,
        ),
        const SizedBox(width: 8),
        _buildMiniIndicator(
          context,
          crop.getSensor(SensorType.ph),
          crop.profile.isPHOptimal,
        ),
        const SizedBox(width: 8),
        _buildMiniIndicator(
          context,
          crop.getSensor(SensorType.light),
          (value) => crop.profile.isLightOptimal(value.toInt()),
        ),
      ],
    );
  }

  Widget _buildMiniIndicator(
    BuildContext context,
    Sensor? sensor,
    Function(double) isOptimal,
  ) {
    if (sensor == null || sensor.currentValue == null) {
      return _buildDot(Colors.grey[400]!, _getIcon(null));
    }

    final status = _getSensorStatus(sensor, isOptimal);
    final color = _getStatusColor(status);

    return _buildDot(color, _getIcon(sensor.type));
  }

  Widget _buildDot(Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  SensorStatus _getSensorStatus(Sensor sensor, Function(double) isOptimal) {
    final value = sensor.currentValue!;

    if (isOptimal(value)) {
      return SensorStatus.optimal;
    }

    // Si está cerca del rango (±15%), warning
    // Esto es simplificado, idealmente usaríamos la lógica completa de SensorGauge
    return SensorStatus.warning;
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

  IconData _getIcon(SensorType? type) {
    if (type == null) return Icons.sensors;

    switch (type) {
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
