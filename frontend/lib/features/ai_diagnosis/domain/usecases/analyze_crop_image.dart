import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/error/failures.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/repositories/ai_diagnosis_repository.dart';

class AnalyzeCropImage {
  final AiDiagnosisRepository repository;

  AnalyzeCropImage(this.repository);

  Future<Either<Failure, VisionAnalysis>> call(String cropId, File image) async {
    return await repository.analyzeCropImage(cropId, image);
  }
}
