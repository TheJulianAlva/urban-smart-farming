import 'package:urban_smart_farming/core/utils/constants.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';

class SensorReadingModel {
  final double temperature;
  final double humidity; // avg_soil_moisture del backend
  final double lightLevel; // avg_light del backend
  final DateTime timestamp;

  const SensorReadingModel({
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
    required this.timestamp,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      temperature: (json['avg_temperature'] as num).toDouble(),
      humidity: (json['avg_soil_moisture'] as num).toDouble(),
      lightLevel: (json['avg_light'] as num).toDouble(),
      timestamp: DateTime.parse(json['recorded_at'] as String),
    );
  }

  SensorReadingEntity toEntity(String cropId) {
    return SensorReadingEntity(
      cropId: cropId,
      temperature: temperature,
      humidity: humidity,
      lightLevel: lightLevel,
      timestamp: timestamp,
      temperatureStatus: _getStatus(temperature, 'temperature'),
      humidityStatus: _getStatus(humidity, 'humidity'),
      lightStatus: _getStatus(lightLevel, 'light'),
    );
  }

  static SensorStatus _getStatus(double value, String metric) {
    final ranges = AppConstants.optimalRanges[metric];
    if (ranges == null) return SensorStatus.optimal;
    final min = ranges['min']!;
    final max = ranges['max']!;
    if (value < min * 0.8 || value > max * 1.2) return SensorStatus.danger;
    if (value < min || value > max) return SensorStatus.warning;
    return SensorStatus.optimal;
  }
}
