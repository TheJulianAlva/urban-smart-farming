import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Caso de uso para obtener estado de actuadores
class GetActuatorStatusesUseCase {
  final DashboardRepository repository;

  GetActuatorStatusesUseCase(this.repository);

  Future<Either<Failure, List<ActuatorStatusEntity>>> call() async {
    return await repository.getActuatorStatuses();
  }
}
