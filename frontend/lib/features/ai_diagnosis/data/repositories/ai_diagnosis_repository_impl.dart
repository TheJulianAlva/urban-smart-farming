import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/error/failures.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/repositories/ai_diagnosis_repository.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/data/datasources/ai_diagnosis_remote_datasource.dart';

class AiDiagnosisRepositoryImpl implements AiDiagnosisRepository {
  final AiDiagnosisRemoteDataSource remoteDataSource;

  AiDiagnosisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VisionAnalysis>> analyzeCropImage(String cropId, File image) async {
    try {
      final remoteAnalysis = await remoteDataSource.analyzeCropImage(cropId, image);
      return Right(remoteAnalysis);
    } catch (e) {
      if (e is ServerFailure) return Left(ServerFailure(e.message));
      if (e is ConnectionFailure) return Left(e);
      return const Left(ConnectionFailure('Error de red al analizar la imagen.'));
    }
  }
}
