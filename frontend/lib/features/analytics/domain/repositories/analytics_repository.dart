import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, List<SensorReadingHistoryEntity>>> getSensorHistory(
    String cropId,
    String range, // 'day' | 'week' | 'month'
  );
}
