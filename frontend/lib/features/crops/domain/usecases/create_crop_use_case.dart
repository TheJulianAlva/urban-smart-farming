import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

/// Caso de uso para crear un nuevo cultivo
class CreateCropUseCase {
  final CropRepository repository;

  CreateCropUseCase(this.repository);

  Future<Either<Failure, CropEntity>> call({
    required String name,
    required String plantType,
    required String location,
  }) async {
    // Validar que el nombre no esté vacío
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure('El nombre del cultivo es requerido'),
      );
    }

    // Validar que la ubicación no esté vacía
    if (location.trim().isEmpty) {
      return const Left(ValidationFailure('La ubicación es requerida'));
    }

    return await repository.createCrop(
      name: name,
      plantType: plantType,
      location: location,
    );
  }
}
