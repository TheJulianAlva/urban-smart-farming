import 'package:equatable/equatable.dart';

/// Estado del sensor
enum SensorStatus { optimal, warning, danger, offline }

/// Lectura de sensores
class SensorReadingEntity extends Equatable {
  final double temperature; // °C
  final double humidity; // %
  final double lightLevel; // Lux
  final double ph; // pH level
  final DateTime timestamp;
  final SensorStatus temperatureStatus;
  final SensorStatus humidityStatus;
  final SensorStatus lightStatus;
  final SensorStatus phStatus;

  const SensorReadingEntity({
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
    required this.ph,
    required this.timestamp,
    required this.temperatureStatus,
    required this.humidityStatus,
    required this.lightStatus,
    required this.phStatus,
  });

  @override
  List<Object?> get props => [
    temperature,
    humidity,
    lightLevel,
    ph,
    timestamp,
    temperatureStatus,
    humidityStatus,
    lightStatus,
    phStatus,
  ];
}
