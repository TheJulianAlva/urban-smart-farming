import 'package:equatable/equatable.dart';

/// Un punto de lectura histórica de sensores para gráficas
class SensorReadingHistoryEntity extends Equatable {
  final DateTime timestamp;
  final double? temperature; // °C
  final double? humidity; // % (humedad del suelo)
  final double? lightLevel; // Lux

  const SensorReadingHistoryEntity({
    required this.timestamp,
    this.temperature,
    this.humidity,
    this.lightLevel,
  });

  @override
  List<Object?> get props => [timestamp, temperature, humidity, lightLevel];
}
