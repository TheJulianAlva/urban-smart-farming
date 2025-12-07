import 'package:equatable/equatable.dart';

/// Tipos de actuadores disponibles
enum ActuatorType {
  waterPump, // Bomba de riego
  ledLight, // Luz LED
}

/// Entidad de Actuador
class Actuator extends Equatable {
  final String id;
  final ActuatorType type;
  final String pin; // Pin del microcontrolador (ej: "D5")
  final bool isOn; // Estado actual (encendido/apagado)
  final int? intensity; // Intensidad (0-100%), solo para LED
  final DateTime? lastActivation; // Última vez que se activó
  final bool isActive; // Si el actuador está funcionando

  const Actuator({
    required this.id,
    required this.type,
    required this.pin,
    required this.isOn,
    this.intensity,
    this.lastActivation,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    pin,
    isOn,
    intensity,
    lastActivation,
    isActive,
  ];

  Actuator copyWith({
    String? id,
    ActuatorType? type,
    String? pin,
    bool? isOn,
    int? intensity,
    DateTime? lastActivation,
    bool? isActive,
  }) {
    return Actuator(
      id: id ?? this.id,
      type: type ?? this.type,
      pin: pin ?? this.pin,
      isOn: isOn ?? this.isOn,
      intensity: intensity ?? this.intensity,
      lastActivation: lastActivation ?? this.lastActivation,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Helper para obtener el nombre del actuador
  String get name {
    switch (type) {
      case ActuatorType.waterPump:
        return 'Bomba de Riego';
      case ActuatorType.ledLight:
        return 'Luz LED';
    }
  }

  /// Helper para validar intensidad (solo en LED)
  bool get hasIntensityControl => type == ActuatorType.ledLight;

  @override
  String toString() =>
      'Actuator(id: $id, type: $type, isOn: $isOn${intensity != null ? ', intensity: $intensity%' : ''})';
}
