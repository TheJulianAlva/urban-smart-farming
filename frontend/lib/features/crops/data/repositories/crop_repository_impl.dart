import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/data/models/crop_model.dart';
import 'package:urban_smart_farming/features/crops/data/models/mock_pot_factory.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

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
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Usuario no autenticado'));

      final response = await client
          .from('Crop')
          .select('*, CropProfile(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final crops = (response as List<dynamic>).map((row) {
        final entity = CropModel.fromJson(row as Map<String, dynamic>);
        return entity.copyWith(
          pot: MockPotFactory.createMockPot(
            id: 'pot-${entity.id}',
            cropId: entity.id,
          ),
        );
      }).toList();

      return Right(crops);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Error de base de datos: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error al obtener cultivos: $e'));
    }
  }

  @override
  Future<Either<Failure, CropEntity>> getCropById(String cropId) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Usuario no autenticado'));

      final response = await client
          .from('Crop')
          .select('*, CropProfile(*)')
          .eq('id', cropId)
          .eq('user_id', userId)
          .single();

      final entity = CropModel.fromJson(response as Map<String, dynamic>);
      return Right(entity.copyWith(
        pot: MockPotFactory.createMockPot(
          id: 'pot-${entity.id}',
          cropId: entity.id,
        ),
      ));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Left(ServerFailure('Cultivo con ID $cropId no encontrado'));
      }
      return Left(ServerFailure('Error de base de datos: ${e.message}'));
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

  @override
  Future<Either<Failure, List<PlantProfile>>> getUserProfiles() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Usuario no autenticado'));

      final response = await client
          .from('CropProfile')
          .select()
          .eq('creator_id', userId)
          .order('profile_name', ascending: true);

      final profiles = (response as List<dynamic>).map((row) {
        final json = row as Map<String, dynamic>;
        return PlantProfile(
          id: json['id'] as String,
          name: (json['profile_name'] as String?) ?? 'Sin nombre',
          description: 'Perfil personalizado',
          minSoilMoisture: (json['min_moisture'] as num?)?.toDouble() ?? 50.0,
          maxSoilMoisture: (json['max_moisture'] as num?)?.toDouble() ?? 80.0,
          minTemperature: (json['ideal_temperature'] as num?)?.toDouble() ?? 15.0,
          maxTemperature: (json['ideal_temperature'] as num?)?.toDouble() ?? 30.0,
          minPH: 6.0,
          maxPH: 7.5,
          requiredLightHours: 6,
          optimalLux: 8000,
          isPredefined: false,
        );
      }).toList();

      return Right(profiles);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Error de base de datos: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error al obtener perfiles: $e'));
    }
  }
}
