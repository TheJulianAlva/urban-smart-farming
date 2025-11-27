import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';

/// Estados del Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final SensorReadingEntity sensorData;
  final List<ActuatorStatusEntity> actuators;

  const DashboardLoaded({required this.sensorData, required this.actuators});

  @override
  List<Object?> get props => [sensorData, actuators];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
