import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';

/// Repositorio de Cultivos
abstract class CropRepository {
  /// Obtener todos los cultivos del usuario
  Future<Either<Failure, List<CropEntity>>> getUserCrops();

  /// Obtener un cultivo por ID
  Future<Either<Failure, CropEntity>> getCropById(String cropId);

  /// Crear nuevo cultivo
  Future<Either<Failure, CropEntity>> createCrop({
    required String name,
    required String plantType,
    required String location,
  });

  /// Actualizar cultivo existente
  Future<Either<Failure, CropEntity>> updateCrop(CropEntity crop);

  /// Eliminar cultivo
  Future<Either<Failure, void>> deleteCrop(String cropId);
}
