import 'package:equatable/equatable.dart';

/// Estado del sensor
enum SensorStatus { optimal, warning, danger, offline }

/// Lectura de sensores
class SensorReadingEntity extends Equatable {
  final String cropId;
  final double temperature; // °C
  final double humidity; // % (humedad del suelo)
  final double lightLevel; // Lux
  final DateTime timestamp;
  final SensorStatus temperatureStatus;
  final SensorStatus humidityStatus;
  final SensorStatus lightStatus;

  const SensorReadingEntity({
    required this.cropId,
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
    required this.timestamp,
    required this.temperatureStatus,
    required this.humidityStatus,
    required this.lightStatus,
  });

  @override
  List<Object?> get props => [
    cropId,
    temperature,
    humidity,
    lightLevel,
    timestamp,
    temperatureStatus,
    humidityStatus,
    lightStatus,
  ];
}
