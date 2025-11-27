import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

/// Caso de uso para eliminar un cultivo
class DeleteCropUseCase {
  final CropRepository repository;

  DeleteCropUseCase(this.repository);

  Future<Either<Failure, void>> call(String cropId) async {
    return await repository.deleteCrop(cropId);
  }
}
