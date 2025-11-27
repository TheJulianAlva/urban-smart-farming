import 'package:equatable/equatable.dart';

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

  const CropEntity({
    required this.id,
    required this.name,
    required this.plantType,
    required this.location,
    required this.createdAt,
    this.lastUpdate,
    required this.status,
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
  ];

  CropEntity copyWith({
    String? id,
    String? name,
    String? plantType,
    String? location,
    DateTime? createdAt,
    DateTime? lastUpdate,
    CropStatus? status,
  }) {
    return CropEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'CropEntity(id: $id, name: $name, location: $location)';
}
