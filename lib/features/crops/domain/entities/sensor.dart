import 'package:equatable/equatable.dart';

/// Tipos de sensores disponibles
enum SensorType {
  temperature, // Temperatura ambiental
  soilMoisture, // Humedad del suelo
  ph, // pH del suelo
  light, // Iluminación (lux)
}

/// Entidad de Sensor
class Sensor extends Equatable {
  final String id;
  final SensorType type;
  final String pin; // Pin del microcontrolador (ej: "A0")
  final double? currentValue; // Lectura actual
  final DateTime? lastReading; // Última vez que se leyó
  final bool isActive; // Si el sensor está funcionando
  final String unit; // Unidad de medida ("°C", "%", "pH", "lux")

  const Sensor({
    required this.id,
    required this.type,
    required this.pin,
    this.currentValue,
    this.lastReading,
    required this.isActive,
    required this.unit,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    pin,
    currentValue,
    lastReading,
    isActive,
    unit,
  ];

  Sensor copyWith({
    String? id,
    SensorType? type,
    String? pin,
    double? currentValue,
    DateTime? lastReading,
    bool? isActive,
    String? unit,
  }) {
    return Sensor(
      id: id ?? this.id,
      type: type ?? this.type,
      pin: pin ?? this.pin,
      currentValue: currentValue ?? this.currentValue,
      lastReading: lastReading ?? this.lastReading,
      isActive: isActive ?? this.isActive,
      unit: unit ?? this.unit,
    );
  }

  /// Helper para obtener la unidad según el tipo
  static String getUnitForType(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return '°C';
      case SensorType.soilMoisture:
        return '%';
      case SensorType.ph:
        return 'pH';
      case SensorType.light:
        return 'lux';
    }
  }

  /// Helper para obtener el nombre del sensor
  String get name {
    switch (type) {
      case SensorType.temperature:
        return 'Temperatura';
      case SensorType.soilMoisture:
        return 'Humedad del Suelo';
      case SensorType.ph:
        return 'pH del Suelo';
      case SensorType.light:
        return 'Iluminación';
    }
  }

  @override
  String toString() =>
      'Sensor(id: $id, type: $type, value: $currentValue$unit)';
}
