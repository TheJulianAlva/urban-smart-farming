import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';

/// Repositorio de Dashboard
abstract class DashboardRepository {
  /// Obtiene las lecturas actuales de los sensores de un cultivo específico
  Future<Either<Failure, SensorReadingEntity>> getSensorReadings(String cropId);

  /// Obtiene el estado de los actuadores de un cultivo específico
  Future<Either<Failure, List<ActuatorStatusEntity>>> getActuatorStatuses(
    String cropId,
  );
}
