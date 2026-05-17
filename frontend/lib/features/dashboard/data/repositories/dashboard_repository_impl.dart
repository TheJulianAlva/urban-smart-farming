import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SensorReadingEntity>> getSensorReadings(
    String cropId,
  ) async {
    try {
      final model = await remoteDataSource.getSensorReadings(cropId);
      return Right(model.toEntity(cropId));
    } on NoDeviceException {
      return const Left(NoDeviceFailure());
    } catch (_) {
      return const Left(ServerFailure('Error al obtener lecturas del sensor'));
    }
  }

  @override
  Future<Either<Failure, List<ActuatorStatusEntity>>> getActuatorStatuses(
    String cropId,
  ) async {
    try {
      final statuses = await remoteDataSource.getActuatorStatuses(cropId);
      return Right(statuses);
    } catch (_) {
      return const Left(ServerFailure('Error al obtener estado de actuadores'));
    }
  }
}
