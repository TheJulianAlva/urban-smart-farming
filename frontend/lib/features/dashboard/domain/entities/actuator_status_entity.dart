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
  final String cropId; // ID del cultivo asociado
  final String name;
  final ActuatorType type;
  final bool isOn;
  final DateTime lastUpdate;

  const ActuatorStatusEntity({
    required this.id,
    required this.cropId,
    required this.name,
    required this.type,
    required this.isOn,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [id, cropId, name, type, isOn, lastUpdate];

  ActuatorStatusEntity copyWith({
    String? id,
    String? cropId,
    String? name,
    ActuatorType? type,
    bool? isOn,
    DateTime? lastUpdate,
  }) {
    return ActuatorStatusEntity(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
