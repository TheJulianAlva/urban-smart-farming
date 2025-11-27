import 'package:equatable/equatable.dart';

/// Tipo de actuador
enum ActuatorType {
  pump, // Bomba de riego
  light, // Luz LED
  fan, // Ventilación
}

/// Estado de un actuador
class ActuatorStatusEntity extends Equatable {
  final String id;
  final String name;
  final ActuatorType type;
  final bool isOn;
  final DateTime lastUpdate;

  const ActuatorStatusEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [id, name, type, isOn, lastUpdate];

  ActuatorStatusEntity copyWith({
    String? id,
    String? name,
    ActuatorType? type,
    bool? isOn,
    DateTime? lastUpdate,
  }) {
    return ActuatorStatusEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
