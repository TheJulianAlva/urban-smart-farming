import 'package:urban_smart_farming/features/crops/domain/entities/actuator.dart';

/// Modelo de datos para Actuator con serialización JSON
class ActuatorModel {
  final String id;
  final ActuatorType type;
  final String pin;
  final bool isOn;
  final int? intensity;
  final DateTime? lastActivation;
  final bool isActive;

  const ActuatorModel({
    required this.id,
    required this.type,
    required this.pin,
    required this.isOn,
    this.intensity,
    this.lastActivation,
    required this.isActive,
  });

  /// Convertir de entidad a modelo
  factory ActuatorModel.fromEntity(Actuator actuator) {
    return ActuatorModel(
      id: actuator.id,
      type: actuator.type,
      pin: actuator.pin,
      isOn: actuator.isOn,
      intensity: actuator.intensity,
      lastActivation: actuator.lastActivation,
      isActive: actuator.isActive,
    );
  }

  /// Convertir a entidad
  Actuator toEntity() {
    return Actuator(
      id: id,
      type: type,
      pin: pin,
      isOn: isOn,
      intensity: intensity,
      lastActivation: lastActivation,
      isActive: isActive,
    );
  }

  /// Deserializar desde JSON
  factory ActuatorModel.fromJson(Map<String, dynamic> json) {
    return ActuatorModel(
      id: json['id'] as String,
      type: ActuatorType.values.firstWhere(
        (e) => e.toString() == 'ActuatorType.${json['type']}',
        orElse: () => ActuatorType.waterPump,
      ),
      pin: json['pin'] as String,
      isOn: json['isOn'] as bool? ?? false,
      intensity: json['intensity'] as int?,
      lastActivation:
          json['lastActivation'] != null
              ? DateTime.parse(json['lastActivation'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'pin': pin,
      'isOn': isOn,
      'intensity': intensity,
      'lastActivation': lastActivation?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
