import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/config/app_config.dart';
import 'package:urban_smart_farming/features/analytics/data/models/sensor_reading_history_model.dart';
import 'package:urban_smart_farming/features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    show NoDeviceException, DashboardServerException;

abstract class AnalyticsRemoteDataSource {
  Future<List<SensorReadingHistoryModel>> getSensorHistory(
    String cropId,
    String range,
  );
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final http.Client client;

  AnalyticsRemoteDataSourceImpl({required this.client});

  String get _bearerToken {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw const NoDeviceException();
    return session.accessToken;
  }

  @override
  Future<List<SensorReadingHistoryModel>> getSensorHistory(
    String cropId,
    String range,
  ) async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/sensor-readings',
    ).replace(queryParameters: {'crop_id': cropId, 'range': range});

    final response = await client
        .get(uri, headers: {'Authorization': 'Bearer $_bearerToken'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 404) throw const NoDeviceException();
    if (response.statusCode != 200) {
      throw DashboardServerException(response.statusCode);
    }

    final list = json.decode(response.body) as List<dynamic>;
    return list
        .map((item) =>
            SensorReadingHistoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
