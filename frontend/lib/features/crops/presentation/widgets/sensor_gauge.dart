import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

/// Estado del sensor basado en el perfil de la planta
enum SensorStatus {
  optimal, // Dentro del rango óptimo
  warning, // Cerca del límite
  critical, // Fuera de rango
  unknown, // Sin datos
}

/// Widget que muestra un sensor con gauge visual
class SensorGauge extends StatelessWidget {
  final Sensor? sensor;
  final PlantProfile profile;
  final bool compact;

  const SensorGauge({
    super.key,
    required this.sensor,
    required this.profile,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (sensor == null) {
      return _buildNoData(context);
    }

    final status = _getSensorStatus();
    final statusColor = _getStatusColor(status);
    final percentage = _getPercentage();

    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y nombre
              Row(
                children: [
                  Icon(
                    _getSensorIcon(),
                    color: statusColor,
                    size: compact ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sensor!.name,
                      textScaler: MediaQuery.textScalerOf(
                        context,
                      ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.3),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Valor actual
              Text(
                '${sensor!.currentValue?.toStringAsFixed(1) ?? '--'}${sensor!.unit}',
                textScaler: MediaQuery.textScalerOf(
                  context,
                ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Barra de progreso
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),

              // Rango y estado
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  Text(
                    _getOptimalRange(),
                    textScaler: MediaQuery.textScalerOf(
                      context,
                    ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.3),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(status),
                      textScaler: MediaQuery.textScalerOf(
                        context,
                      ).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.0),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoData(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.sensors_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Sin datos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  SensorStatus _getSensorStatus() {
    if (sensor?.currentValue == null) return SensorStatus.unknown;

    final value = sensor!.currentValue!;

    switch (sensor!.type) {
      case SensorType.temperature:
        if (profile.isTemperatureOptimal(value)) return SensorStatus.optimal;
        if (_isNearRange(
          value,
          profile.minTemperature,
          profile.maxTemperature,
        )) {
          return SensorStatus.warning;
        }
        return SensorStatus.critical;

      case SensorType.soilMoisture:
        if (profile.isSoilMoistureOptimal(value)) return SensorStatus.optimal;
        if (_isNearRange(
          value,
          profile.minSoilMoisture,
          profile.maxSoilMoisture,
        )) {
          return SensorStatus.warning;
        }
        return SensorStatus.critical;

      case SensorType.ph:
        if (profile.isPHOptimal(value)) return SensorStatus.optimal;
        if (_isNearRange(value, profile.minPH, profile.maxPH)) {
          return SensorStatus.warning;
        }
        return SensorStatus.critical;

      case SensorType.light:
        final optimalLux = profile.optimalLux.toDouble();
        if (value >= optimalLux * 0.8) return SensorStatus.optimal;
        if (value >= optimalLux * 0.6) return SensorStatus.warning;
        return SensorStatus.critical;
    }
  }

  bool _isNearRange(double value, double min, double max) {
    final margin = (max - min) * 0.15; // 15% de margen
    return value >= (min - margin) && value <= (max + margin);
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

  double _getPercentage() {
    if (sensor?.currentValue == null) return 0.0;

    final value = sensor!.currentValue!;

    switch (sensor!.type) {
      case SensorType.temperature:
        return ((value - profile.minTemperature) /
                (profile.maxTemperature - profile.minTemperature))
            .clamp(0.0, 1.0);

      case SensorType.soilMoisture:
        return (value / 100).clamp(0.0, 1.0);

      case SensorType.ph:
        return ((value - 0) / 14).clamp(0.0, 1.0);

      case SensorType.light:
        return (value / (profile.optimalLux * 1.2)).clamp(0.0, 1.0);
    }
  }

  String _getOptimalRange() {
    switch (sensor!.type) {
      case SensorType.temperature:
        return 'Óptimo: ${profile.minTemperature.toStringAsFixed(0)} - ${profile.maxTemperature.toStringAsFixed(0)}°C';
      case SensorType.soilMoisture:
        return 'Óptimo: ${profile.minSoilMoisture.toStringAsFixed(0)} - ${profile.maxSoilMoisture.toStringAsFixed(0)}%';
      case SensorType.ph:
        return 'Óptimo: ${profile.minPH.toStringAsFixed(1)} - ${profile.maxPH.toStringAsFixed(1)}';
      case SensorType.light:
        return 'Óptimo: ${profile.optimalLux} lux';
    }
  }

  String _getStatusText(SensorStatus status) {
    switch (status) {
      case SensorStatus.optimal:
        return 'Óptimo';
      case SensorStatus.warning:
        return 'Atención';
      case SensorStatus.critical:
        return 'Crítico';
      case SensorStatus.unknown:
        return 'Sin datos';
    }
  }
}
