import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';

/// Modelo de datos para Sensor con serialización JSON
class SensorModel {
  final String id;
  final SensorType type;
  final String pin;
  final double? currentValue;
  final DateTime? lastReading;
  final bool isActive;
  final String unit;

  const SensorModel({
    required this.id,
    required this.type,
    required this.pin,
    this.currentValue,
    this.lastReading,
    required this.isActive,
    required this.unit,
  });

  /// Convertir de entidad a modelo
  factory SensorModel.fromEntity(Sensor sensor) {
    return SensorModel(
      id: sensor.id,
      type: sensor.type,
      pin: sensor.pin,
      currentValue: sensor.currentValue,
      lastReading: sensor.lastReading,
      isActive: sensor.isActive,
      unit: sensor.unit,
    );
  }

  /// Convertir a entidad
  Sensor toEntity() {
    return Sensor(
      id: id,
      type: type,
      pin: pin,
      currentValue: currentValue,
      lastReading: lastReading,
      isActive: isActive,
      unit: unit,
    );
  }

  /// Deserializar desde JSON
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as String,
      type: SensorType.values.firstWhere(
        (e) => e.toString() == 'SensorType.${json['type']}',
        orElse: () => SensorType.temperature,
      ),
      pin: json['pin'] as String,
      currentValue: json['currentValue'] as double?,
      lastReading:
          json['lastReading'] != null
              ? DateTime.parse(json['lastReading'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
      unit: json['unit'] as String,
    );
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'pin': pin,
      'currentValue': currentValue,
      'lastReading': lastReading?.toIso8601String(),
      'isActive': isActive,
      'unit': unit,
    };
  }
}
