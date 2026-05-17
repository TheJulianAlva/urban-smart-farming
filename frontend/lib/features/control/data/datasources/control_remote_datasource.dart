import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/config/app_config.dart';

abstract class ControlRemoteDataSource {
  Future<void> actuate(String deviceId, String actuatorType, String action);
}

class ControlRemoteDataSourceImpl implements ControlRemoteDataSource {
  final http.Client client;

  ControlRemoteDataSourceImpl({required this.client});

  String get _bearerToken {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Sesión expirada');
    return session.accessToken;
  }

  @override
  Future<void> actuate(
    String deviceId,
    String actuatorType,
    String action,
  ) async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/devices/$deviceId/actuate',
    );

    final response = await client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $_bearerToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'actuator_type': actuatorType,
            'action': action,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
