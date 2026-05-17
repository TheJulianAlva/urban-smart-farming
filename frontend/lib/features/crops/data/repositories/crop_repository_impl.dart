import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/config/app_config.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/crops/data/models/crop_model.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

/// Implementación del repositorio de cultivos
class CropRepositoryImpl implements CropRepository {

  @override
  Future<Either<Failure, List<CropEntity>>> getUserCrops() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Usuario no autenticado'));

      final response = await client
          .from('Crop')
          .select('*, CropProfile(*), Device(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final crops = (response as List<dynamic>).map((row) {
        final rowMap = row as Map<String, dynamic>;
        final entity = CropModel.fromJson(rowMap);
        final deviceList = rowMap['Device'] as List<dynamic>?;
        final deviceJson = (deviceList != null && deviceList.isNotEmpty)
            ? deviceList.first as Map<String, dynamic>
            : null;
        return entity.copyWith(pot: _potFromDevice(deviceJson));
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
          .select('*, CropProfile(*), Device(*)')
          .eq('id', cropId)
          .eq('user_id', userId)
          .single();

      final rowMap = response;
      final entity = CropModel.fromJson(rowMap);
      final deviceList = rowMap['Device'] as List<dynamic>?;
      final deviceJson = (deviceList != null && deviceList.isNotEmpty)
          ? deviceList.first as Map<String, dynamic>
          : null;
      return Right(entity.copyWith(pot: _potFromDevice(deviceJson)));
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
    required String profileId,
    required String location,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return const Left(AuthFailure());

      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/v1/crops');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'custom_name': name,
          'profile_id': profileId,
          'location': location,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        return Right(_cropFromCreateResponse(jsonMap, name, location));
      }
      return const Left(ServerFailure('Error al crear cultivo'));
    } on TimeoutException {
      return const Left(ServerFailure('Tiempo de espera agotado'));
    } catch (_) {
      return const Left(ServerFailure('Error de conexión al crear cultivo'));
    }
  }

  /// Construye una entidad mínima desde la respuesta del backend.
  /// Es efímera: el BLoC llama RefreshCrops() inmediatamente después.
  CropEntity _cropFromCreateResponse(
    Map<String, dynamic> jsonMap,
    String name,
    String location,
  ) {
    return CropEntity(
      id: jsonMap['id'] as String,
      name: name,
      plantType: '',
      location: location,
      createdAt: DateTime.now(),
      lastUpdate: DateTime.now(),
      status: CropStatus.active,
      profile:
          PredefinedProfiles.getById('tomatoes') ??
          const PlantProfile(
            id: 'default',
            name: 'Predeterminado',
            description: '',
            minSoilMoisture: 50,
            maxSoilMoisture: 80,
            minTemperature: 18,
            maxTemperature: 28,
            minPH: 6.0,
            maxPH: 7.5,
            requiredLightHours: 8,
            optimalLux: 10000,
          ),
      pot: null,
    );
  }

  /// Construye un [Pot] desde los datos reales de la tabla Device.
  /// Devuelve null si el cultivo no tiene dispositivo registrado.
  /// sensors y actuators se dejan vacíos: Dashboard y Control los obtienen
  /// con sus propios BLoCs.
  Pot? _potFromDevice(Map<String, dynamic>? device) {
    if (device == null) return null;

    final lastHeartbeat = device['last_heartbeat'] != null
        ? DateTime.tryParse(device['last_heartbeat'] as String)
        : null;

    // Conectado si el último heartbeat fue hace menos de 5 minutos
    final isConnected = lastHeartbeat != null &&
        DateTime.now().difference(lastHeartbeat).inMinutes < 5;

    return Pot(
      id: device['id'] as String,
      hardwareId: (device['mac_address'] as String?) ?? '',
      installedAt: lastHeartbeat ?? DateTime.now(),
      isConnected: isConnected,
      lastSync: lastHeartbeat,
      sensors: [],    // datos de sensores los obtiene DashboardBloc
      actuators: [],  // estados de actuadores los obtiene ControlBloc
    );
  }

  @override
  Future<Either<Failure, CropEntity>> updateCrop(CropEntity crop) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return const Left(AuthFailure());

      final uri = Uri.parse(
        '${AppConfig.backendBaseUrl}/api/v1/crops/${crop.id}',
      );
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'custom_name': crop.name,
          'location': crop.location,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return Right(crop);
      return const Left(ServerFailure('Error al actualizar cultivo'));
    } on TimeoutException {
      return const Left(ServerFailure('Tiempo de espera agotado'));
    } catch (_) {
      return const Left(ServerFailure('Error de conexión al actualizar cultivo'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCrop(String cropId) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return const Left(AuthFailure());

      final uri = Uri.parse(
        '${AppConfig.backendBaseUrl}/api/v1/crops/$cropId',
      );
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204) return const Right(null);
      return const Left(ServerFailure('Error al eliminar cultivo'));
    } on TimeoutException {
      return const Left(ServerFailure('Tiempo de espera agotado'));
    } catch (_) {
      return const Left(ServerFailure('Error de conexión al eliminar cultivo'));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice({
    required String cropId,
    required String macAddress,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return const Left(AuthFailure());

      final uri = Uri.parse(
        '${AppConfig.backendBaseUrl}/api/v1/devices/register',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'crop_id': cropId,
          'mac_address': macAddress,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) return const Right(null);
      if (response.statusCode == 409) {
        return const Left(ServerFailure('MAC ya registrada'));
      }
      return const Left(ServerFailure('Error al registrar dispositivo'));
    } on TimeoutException {
      return const Left(ServerFailure('Tiempo de espera agotado'));
    } catch (_) {
      return const Left(
        ServerFailure('Error de conexión al registrar dispositivo'),
      );
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
