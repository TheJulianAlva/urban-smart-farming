import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Caso de uso para obtener lecturas de sensores
class GetSensorDataUseCase {
  final DashboardRepository repository;

  GetSensorDataUseCase(this.repository);

  Future<Either<Failure, SensorReadingEntity>> call(String cropId) async {
    return await repository.getSensorReadings(cropId);
  }
}
