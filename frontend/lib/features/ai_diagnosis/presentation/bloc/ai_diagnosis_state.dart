import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';

abstract class AiDiagnosisState extends Equatable {
  const AiDiagnosisState();

  @override
  List<Object> get props => [];
}

/// Estado inicial: sin imagen seleccionada.
class AiDiagnosisInitial extends AiDiagnosisState {}

/// El usuario seleccionó una imagen, esperando confirmación para analizar.
class AiDiagnosisImageSelected extends AiDiagnosisState {
  final String imagePath;

  const AiDiagnosisImageSelected(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// El análisis está en curso.
class AiDiagnosisAnalyzing extends AiDiagnosisState {
  final String imagePath;

  const AiDiagnosisAnalyzing(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// El análisis finalizó con éxito y se muestran los resultados.
class AiDiagnosisResult extends AiDiagnosisState {
  final String imagePath;
  final String severity;
  final String problemName;
  final String affectedArea;
  final String problemDescription;
  final List<String> recommendations;
  final List<String> preventionTips;

  const AiDiagnosisResult({
    required this.imagePath,
    required this.severity,
    required this.problemName,
    required this.affectedArea,
    required this.problemDescription,
    required this.recommendations,
    required this.preventionTips,
  });

  @override
  List<Object> get props => [
        imagePath,
        severity,
        problemName,
        affectedArea,
        problemDescription,
        recommendations,
        preventionTips,
      ];
}

/// Carga genérica (uso programático con AnalyzeImageEvent).
class AiDiagnosisLoading extends AiDiagnosisState {}

/// Éxito genérico con entidad VisionAnalysis completa.
class AiDiagnosisSuccess extends AiDiagnosisState {
  final VisionAnalysis analysis;

  const AiDiagnosisSuccess({required this.analysis});

  @override
  List<Object> get props => [analysis];
}

/// Error durante el análisis.
class AiDiagnosisError extends AiDiagnosisState {
  final String message;

  const AiDiagnosisError({required this.message});

  @override
  List<Object> get props => [message];
}
