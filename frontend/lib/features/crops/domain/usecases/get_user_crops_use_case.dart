import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

/// Caso de uso para obtener todos los cultivos del usuario
class GetUserCropsUseCase {
  final CropRepository repository;

  GetUserCropsUseCase(this.repository);

  Future<Either<Failure, List<CropEntity>>> call() async {
    return await repository.getUserCrops();
  }
}
