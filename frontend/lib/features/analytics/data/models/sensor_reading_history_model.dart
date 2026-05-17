import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';

class SensorReadingHistoryModel {
  final double? temperature;
  final double? humidity;
  final double? lightLevel;
  final DateTime? timestamp;

  const SensorReadingHistoryModel({
    this.temperature,
    this.humidity,
    this.lightLevel,
    this.timestamp,
  });

  factory SensorReadingHistoryModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingHistoryModel(
      temperature: json['avg_temperature'] != null
          ? (json['avg_temperature'] as num).toDouble()
          : null,
      humidity: json['avg_soil_moisture'] != null
          ? (json['avg_soil_moisture'] as num).toDouble()
          : null,
      lightLevel: json['avg_light'] != null
          ? (json['avg_light'] as num).toDouble()
          : null,
      timestamp: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
    );
  }

  SensorReadingHistoryEntity toEntity() {
    return SensorReadingHistoryEntity(
      timestamp: timestamp ?? DateTime.now(),
      temperature: temperature,
      humidity: humidity,
      lightLevel: lightLevel,
    );
  }
}
