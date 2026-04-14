import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/actuator.dart';

/// Entidad de Maceta (Pot)
/// Representa el hardware físico con sensores y actuadores
class Pot extends Equatable {
  final String id;
  final String hardwareId; // ID único del módulo ESP32/Arduino
  final String? name; // Nombre opcional (ej: "Módulo Balcón #1")
  final DateTime installedAt; // Fecha de instalación
  final bool isConnected; // Estado de conexión actual
  final DateTime? lastSync; // Última sincronización con el hardware

  // Sensores y actuadores
  final List<Sensor> sensors;
  final List<Actuator> actuators;

  const Pot({
    required this.id,
    required this.hardwareId,
    this.name,
    required this.installedAt,
    required this.isConnected,
    this.lastSync,
    required this.sensors,
    required this.actuators,
  });

  @override
  List<Object?> get props => [
    id,
    hardwareId,
    name,
    installedAt,
    isConnected,
    lastSync,
    sensors,
    actuators,
  ];

  Pot copyWith({
    String? id,
    String? hardwareId,
    String? name,
    DateTime? installedAt,
    bool? isConnected,
    DateTime? lastSync,
    List<Sensor>? sensors,
    List<Actuator>? actuators,
  }) {
    return Pot(
      id: id ?? this.id,
      hardwareId: hardwareId ?? this.hardwareId,
      name: name ?? this.name,
      installedAt: installedAt ?? this.installedAt,
      isConnected: isConnected ?? this.isConnected,
      lastSync: lastSync ?? this.lastSync,
      sensors: sensors ?? this.sensors,
      actuators: actuators ?? this.actuators,
    );
  }

  /// Obtener sensor por tipo
  Sensor? getSensorByType(SensorType type) {
    try {
      return sensors.firstWhere((sensor) => sensor.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Obtener actuador por tipo
  Actuator? getActuatorByType(ActuatorType type) {
    try {
      return actuators.firstWhere((actuator) => actuator.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si todos los sensores están activos
  bool get allSensorsActive => sensors.every((sensor) => sensor.isActive);

  /// Verificar si todos los actuadores están activos
  bool get allActuatorsActive =>
      actuators.every((actuator) => actuator.isActive);

  /// Número de sensores con lecturas recientes (últimas 5 minutos)
  int get activeSensorCount {
    final now = DateTime.now();
    return sensors
        .where(
          (sensor) =>
              sensor.lastReading != null &&
              now.difference(sensor.lastReading!).inMinutes < 5,
        )
        .length;
  }

  @override
  String toString() =>
      'Pot(id: $id, hardwareId: $hardwareId, sensors: ${sensors.length}, actuators: ${actuators.length}, connected: $isConnected)';
}
