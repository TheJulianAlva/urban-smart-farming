import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/data/models/sensor_model.dart';
import 'package:urban_smart_farming/features/crops/data/models/actuator_model.dart';

/// Modelo de datos para Pot con serialización JSON
class PotModel {
  final String id;
  final String hardwareId;
  final String? name;
  final DateTime installedAt;
  final bool isConnected;
  final DateTime? lastSync;
  final List<SensorModel> sensors;
  final List<ActuatorModel> actuators;

  const PotModel({
    required this.id,
    required this.hardwareId,
    this.name,
    required this.installedAt,
    required this.isConnected,
    this.lastSync,
    required this.sensors,
    required this.actuators,
  });

  /// Convertir de entidad a modelo
  factory PotModel.fromEntity(Pot pot) {
    return PotModel(
      id: pot.id,
      hardwareId: pot.hardwareId,
      name: pot.name,
      installedAt: pot.installedAt,
      isConnected: pot.isConnected,
      lastSync: pot.lastSync,
      sensors: pot.sensors.map((s) => SensorModel.fromEntity(s)).toList(),
      actuators: pot.actuators.map((a) => ActuatorModel.fromEntity(a)).toList(),
    );
  }

  /// Convertir a entidad
  Pot toEntity() {
    return Pot(
      id: id,
      hardwareId: hardwareId,
      name: name,
      installedAt: installedAt,
      isConnected: isConnected,
      lastSync: lastSync,
      sensors: sensors.map((s) => s.toEntity()).toList(),
      actuators: actuators.map((a) => a.toEntity()).toList(),
    );
  }

  /// Deserializar desde JSON
  factory PotModel.fromJson(Map<String, dynamic> json) {
    return PotModel(
      id: json['id'] as String,
      hardwareId: json['hardwareId'] as String,
      name: json['name'] as String?,
      installedAt: DateTime.parse(json['installedAt'] as String),
      isConnected: json['isConnected'] as bool? ?? false,
      lastSync:
          json['lastSync'] != null
              ? DateTime.parse(json['lastSync'] as String)
              : null,
      sensors:
          (json['sensors'] as List<dynamic>?)
              ?.map((s) => SensorModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      actuators:
          (json['actuators'] as List<dynamic>?)
              ?.map((a) => ActuatorModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hardwareId': hardwareId,
      'name': name,
      'installedAt': installedAt.toIso8601String(),
      'isConnected': isConnected,
      'lastSync': lastSync?.toIso8601String(),
      'sensors': sensors.map((s) => s.toJson()).toList(),
      'actuators': actuators.map((a) => a.toJson()).toList(),
    };
  }
}
