import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/config/app_config.dart';
import 'package:urban_smart_farming/features/dashboard/data/models/sensor_reading_model.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';

/// Excepción: cultivo sin dispositivo registrado
class NoDeviceException implements Exception {
  const NoDeviceException();
}

/// Excepción: error de servidor
class DashboardServerException implements Exception {
  final int statusCode;
  const DashboardServerException(this.statusCode);
}

abstract class DashboardRemoteDataSource {
  Future<SensorReadingModel> getSensorReadings(String cropId);
  Future<List<ActuatorStatusEntity>> getActuatorStatuses(String cropId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final http.Client client;

  DashboardRemoteDataSourceImpl({required this.client});

  String get _bearerToken {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw const NoDeviceException();
    return session.accessToken;
  }

  @override
  Future<SensorReadingModel> getSensorReadings(String cropId) async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/sensor-readings/latest',
    ).replace(queryParameters: {'crop_id': cropId});

    final response = await client
        .get(uri, headers: {'Authorization': 'Bearer $_bearerToken'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 404) throw const NoDeviceException();
    if (response.statusCode != 200) {
      throw DashboardServerException(response.statusCode);
    }

    return SensorReadingModel.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ActuatorStatusEntity>> getActuatorStatuses(String cropId) async {
    final supabase = Supabase.instance.client;

    // Buscar el device asociado al cultivo
    final devices = await supabase
        .from('Device')
        .select('id')
        .eq('crop_id', cropId)
        .limit(1);

    if (devices.isEmpty) return [];

    final deviceId = devices[0]['id'] as String;

    // Consultar último evento por tipo de actuador en paralelo
    final results = await Future.wait([
      supabase
          .from('ActuationEvent')
          .select('id, actuator_type, action, started_at')
          .eq('device_id', deviceId)
          .eq('actuator_type', 'pump')
          .order('started_at', ascending: false)
          .limit(1),
      supabase
          .from('ActuationEvent')
          .select('id, actuator_type, action, started_at')
          .eq('device_id', deviceId)
          .eq('actuator_type', 'light')
          .order('started_at', ascending: false)
          .limit(1),
    ]);

    final statuses = <ActuatorStatusEntity>[];

    void addIfPresent(
      List<dynamic> events,
      String name,
      ActuatorType type,
    ) {
      if (events.isEmpty) return;
      final e = events[0] as Map<String, dynamic>;
      statuses.add(ActuatorStatusEntity(
        id: e['id'] as String,
        cropId: cropId,
        name: name,
        type: type,
        isOn: e['action'] == 'on',
        lastUpdate: DateTime.parse(e['started_at'] as String),
      ));
    }

    addIfPresent(results[0], 'Bomba de Riego', ActuatorType.pump);
    addIfPresent(results[1], 'Luz LED', ActuatorType.light);

    return statuses;
  }
}
