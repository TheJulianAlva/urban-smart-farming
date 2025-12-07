import 'package:equatable/equatable.dart';

/// Entidad de lectura de sensor (para historial)
class SensorReading extends Equatable {
  final String id;
  final String sensorId; // ID del sensor que generó la lectura
  final String cropId; // ID del cultivo al que pertenece
  final double value; // Valor leído
  final DateTime timestamp; // Momento de la lectura
  final String unit; // Unidad de medida

  const SensorReading({
    required this.id,
    required this.sensorId,
    required this.cropId,
    required this.value,
    required this.timestamp,
    required this.unit,
  });

  @override
  List<Object?> get props => [id, sensorId, cropId, value, timestamp, unit];

  SensorReading copyWith({
    String? id,
    String? sensorId,
    String? cropId,
    double? value,
    DateTime? timestamp,
    String? unit,
  }) {
    return SensorReading(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      cropId: cropId ?? this.cropId,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() =>
      'SensorReading(sensorId: $sensorId, value: $value$unit, time: $timestamp)';
}
