import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:urban_smart_farming/features/ai_diagnosis/data/models/vision_analysis_model.dart';
import 'package:urban_smart_farming/core/error/failures.dart';

abstract class AiDiagnosisRemoteDataSource {
  Future<VisionAnalysisModel> analyzeCropImage(String cropId, File image);
}

class AiDiagnosisRemoteDataSourceImpl implements AiDiagnosisRemoteDataSource {
  final http.Client client;

  AiDiagnosisRemoteDataSourceImpl({required this.client});

  @override
  Future<VisionAnalysisModel> analyzeCropImage(String cropId, File image) async {
    // URL base puede venir de variables de entorno. Se usa local para demostración.
    final uri = Uri.parse('http://localhost:8000/api/v1/vision/analyze');

    // Aquí normalmente obtendrías el token de autenticación
    final String token = 'TU_TOKEN_SUPABASE_AQUI'; 

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields['crop_id'] = cropId
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonMap = json.decode(responseBody);
        return VisionAnalysisModel.fromJson(jsonMap);
      } else {
        throw ServerFailure('Error servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const ConnectionFailure('No se pudo conectar al servidor IA.');
    }
  }
}
