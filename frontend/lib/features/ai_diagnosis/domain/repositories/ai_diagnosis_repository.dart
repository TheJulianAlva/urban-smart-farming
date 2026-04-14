import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/error/failures.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';

abstract class AiDiagnosisRepository {
  Future<Either<Failure, VisionAnalysis>> analyzeCropImage(String cropId, File image);
}
