import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';
import 'package:urban_smart_farming/features/analytics/domain/repositories/analytics_repository.dart';

class GetSensorHistoryUseCase {
  final AnalyticsRepository repository;

  const GetSensorHistoryUseCase(this.repository);

  Future<Either<Failure, List<SensorReadingHistoryEntity>>> call(
    String cropId,
    String range,
  ) {
    return repository.getSensorHistory(cropId, range);
  }
}
