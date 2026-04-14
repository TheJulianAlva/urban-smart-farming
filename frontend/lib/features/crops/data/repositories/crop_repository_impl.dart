import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/data/models/mock_pot_factory.dart';

/// Implementación mock del repositorio de cultivos
class CropRepositoryImpl implements CropRepository {
  // Lista de cultivos mock (máximo 10)
  final List<CropEntity> _crops = [
    CropEntity(
      id: '1',
      name: 'Tomates del Balcón',
      plantType: 'Tomate Cherry',
      location: 'Balcón Norte',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      status: CropStatus.active,
      profile: PredefinedProfiles.getById('tomatoes')!,
      pot: MockPotFactory.createMockPot(id: 'pot-1', cropId: '1'),
    ),
    CropEntity(
      id: '2',
      name: 'Lechugas Hidropónicas',
      plantType: 'Lechuga Romana',
      location: 'Cocina',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 12)),
      status: CropStatus.active,
      profile: PredefinedProfiles.getById('lettuce')!,
      pot: MockPotFactory.createMockPot(id: 'pot-2', cropId: '2'),
    ),
    CropEntity(
      id: '3',
      name: 'Albahaca Aromática',
      plantType: 'Albahaca',
      location: 'Ventana Sur',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
      status: CropStatus.active,
      profile: PredefinedProfiles.getById('basil')!,
      pot: null, // Sin hardware
    ),
  ];

  @override
  Future<Either<Failure, List<CropEntity>>> getUserCrops() async {
    try {
      // Simular latencia de red
      await Future.delayed(const Duration(milliseconds: 500));

      // Retornar solo cultivos activos
      final activeCrops =
          _crops.where((c) => c.status == CropStatus.active).toList();
      return Right(activeCrops);
    } catch (e) {
      return const Left(ServerFailure('Error al obtener cultivos'));
    }
  }

  @override
  Future<Either<Failure, CropEntity>> getCropById(String cropId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final crop = _crops.firstWhere(
        (c) => c.id == cropId,
        orElse: () => throw Exception('Cultivo no encontrado'),
      );

      return Right(crop);
    } catch (e) {
      return Left(ServerFailure('Cultivo con ID $cropId no encontrado'));
    }
  }

  @override
  Future<Either<Failure, CropEntity>> createCrop({
    required String name,
    required String plantType,
    required String location,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      // Verificar límite de 10 cultivos
      if (_crops.length >= 10) {
        return const Left(ValidationFailure('Límite de 10 cultivos alcanzado'));
      }

      // Generar nuevo ID
      final newId = (_crops.length + 1).toString();

      // Usar perfil predefinido o crear uno básico
      final profile =
          PredefinedProfiles.getById('tomatoes') ??
          const PlantProfile(
            id: 'default',
            name: 'Predeterminado',
            description: 'Perfil predeterminado',
            minSoilMoisture: 50,
            maxSoilMoisture: 80,
            minTemperature: 18,
            maxTemperature: 28,
            minPH: 6.0,
            maxPH: 7.5,
            requiredLightHours: 8,
            optimalLux: 10000,
          );

      final newCrop = CropEntity(
        id: newId,
        name: name,
        plantType: plantType,
        location: location,
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
        status: CropStatus.active,
        profile: profile,
        pot: null, // Sin hardware por defecto
      );

      _crops.add(newCrop);
      return Right(newCrop);
    } catch (e) {
      return const Left(ServerFailure('Error al crear cultivo'));
    }
  }

  @override
  Future<Either<Failure, CropEntity>> updateCrop(CropEntity crop) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _crops.indexWhere((c) => c.id == crop.id);
      if (index == -1) {
        return const Left(ServerFailure('Cultivo no encontrado'));
      }

      _crops[index] = crop.copyWith(lastUpdate: DateTime.now());
      return Right(_crops[index]);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar cultivo'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCrop(String cropId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _crops.indexWhere((c) => c.id == cropId);
      if (index == -1) {
        return const Left(ServerFailure('Cultivo no encontrado'));
      }

      _crops.removeAt(index);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al eliminar cultivo'));
    }
  }
}
