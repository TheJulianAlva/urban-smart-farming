import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/config/app_config.dart';
import 'package:urban_smart_farming/core/error/failures.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/data/models/vision_analysis_model.dart';

abstract class AiDiagnosisRemoteDataSource {
  Future<VisionAnalysisModel> analyzeCropImage(String cropId, File image);
}

class AiDiagnosisRemoteDataSourceImpl implements AiDiagnosisRemoteDataSource {
  final http.Client client;

  AiDiagnosisRemoteDataSourceImpl({required this.client});

  @override
  Future<VisionAnalysisModel> analyzeCropImage(
    String cropId,
    File image,
  ) async {
    // URL base puede venir de variables de entorno. Se usa local para demostración.
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/v1/vision/analyze');

    // Token obtenido de la sesión activa de Supabase
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw const ConnectionFailure('Sesión expirada. Iniciá sesión nuevamente.');
    }
    final token = session.accessToken;

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    if (cropId.isNotEmpty) {
      request.fields['crop_id'] = cropId;
    }

    try {
      final response = await request.send().timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw const ConnectionFailure(
          'El análisis tardó demasiado. Intentá con una imagen más pequeña.',
        ),
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonMap = json.decode(responseBody);
        return VisionAnalysisModel.fromJson(jsonMap);
      } else {
        throw ServerFailure('Error servidor: ${response.statusCode}');
      }
    } on ConnectionFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw const ConnectionFailure('No se pudo conectar al servidor IA.');
    }
  }
}
