import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';
import 'package:urban_smart_farming/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:urban_smart_farming/features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    show NoDeviceException;

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SensorReadingHistoryEntity>>> getSensorHistory(
    String cropId,
    String range,
  ) async {
    try {
      final models = await remoteDataSource.getSensorHistory(cropId, range);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NoDeviceException {
      return const Left(NoDeviceFailure());
    } catch (_) {
      return const Left(ServerFailure('Error al obtener historial de lecturas'));
    }
  }
}
