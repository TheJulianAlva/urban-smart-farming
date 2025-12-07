import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/actuator.dart';

/// Estado del cultivo
enum CropStatus {
  active, // Cultivo activo
  paused, // Cultivo pausado
  archived, // Cultivo archivado
}

/// Entidad de Cultivo
class CropEntity extends Equatable {
  final String id;
  final String name; // "Tomates del Balcón"
  final String plantType; // "Tomate Cherry"
  final String location; // "Balcón Norte"
  final DateTime createdAt;
  final DateTime? lastUpdate; // Última actualización de sensores
  final CropStatus status;

  // NUEVO: Perfil de la planta con parámetros óptimos
  final PlantProfile profile;

  // NUEVO: Maceta con sensores y actuadores (opcional)
  final Pot? pot;

  const CropEntity({
    required this.id,
    required this.name,
    required this.plantType,
    required this.location,
    required this.createdAt,
    this.lastUpdate,
    required this.status,
    required this.profile,
    this.pot,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    plantType,
    location,
    createdAt,
    lastUpdate,
    status,
    profile,
    pot,
  ];

  // Helpers para acceso rápido a sensores y actuadores
  bool get hasHardware => pot != null && pot!.isConnected;
  List<Sensor> get sensors => pot?.sensors ?? [];
  List<Actuator> get actuators => pot?.actuators ?? [];

  // Helper para obtener sensor específico
  Sensor? getSensor(SensorType type) => pot?.getSensorByType(type);

  // Helper para obtener actuador específico
  Actuator? getActuator(ActuatorType type) => pot?.getActuatorByType(type);

  CropEntity copyWith({
    String? id,
    String? name,
    String? plantType,
    String? location,
    DateTime? createdAt,
    DateTime? lastUpdate,
    CropStatus? status,
    PlantProfile? profile,
    Pot? pot,
  }) {
    return CropEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      pot: pot ?? this.pot,
    );
  }

  @override
  String toString() => 'CropEntity(id: $id, name: $name, location: $location)';
}
