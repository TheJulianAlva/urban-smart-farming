import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/usecases/analyze_crop_image.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_event.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_state.dart';

class AiDiagnosisBloc extends Bloc<AiDiagnosisEvent, AiDiagnosisState> {
  final AnalyzeCropImage analyzeCropImage;
  final String cropId;

  AiDiagnosisBloc({required this.analyzeCropImage, required this.cropId})
      : super(AiDiagnosisInitial()) {
    on<ImageSelected>(_onImageSelected);
    on<AnalysisRequested>(_onAnalysisRequested);
    on<AnalysisReset>(_onAnalysisReset);
    on<AnalyzeImageEvent>(_onAnalyzeImageEvent);
  }

  void _onImageSelected(
    ImageSelected event,
    Emitter<AiDiagnosisState> emit,
  ) {
    emit(AiDiagnosisImageSelected(event.imagePath));
  }

  Future<void> _onAnalysisRequested(
    AnalysisRequested event,
    Emitter<AiDiagnosisState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AiDiagnosisImageSelected) return;

    final imagePath = currentState.imagePath;
    emit(AiDiagnosisAnalyzing(imagePath));

    final failureOrAnalysis = await analyzeCropImage(cropId, File(imagePath));

    failureOrAnalysis.fold(
      (failure) => emit(AiDiagnosisError(message: failure.message)),
      (analysis) => emit(
        AiDiagnosisResult(
          imagePath: imagePath,
          severity: analysis.severity,
          problemName: analysis.problemName,
          affectedArea: analysis.affectedArea,
          problemDescription: analysis.problemDescription,
          recommendations: analysis.recommendations,
          preventionTips: analysis.preventionTips,
        ),
      ),
    );
  }

  void _onAnalysisReset(
    AnalysisReset event,
    Emitter<AiDiagnosisState> emit,
  ) {
    emit(AiDiagnosisInitial());
  }

  Future<void> _onAnalyzeImageEvent(
    AnalyzeImageEvent event,
    Emitter<AiDiagnosisState> emit,
  ) async {
    emit(AiDiagnosisLoading());
    final failureOrAnalysis = await analyzeCropImage(event.cropId, event.image);
    failureOrAnalysis.fold(
      (failure) => emit(AiDiagnosisError(message: failure.message)),
      (analysis) => emit(AiDiagnosisSuccess(analysis: analysis)),
    );
  }
}
