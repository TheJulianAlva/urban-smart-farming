import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';

abstract class AiDiagnosisState extends Equatable {
  const AiDiagnosisState();
  
  @override
  List<Object> get props => [];
}

class AiDiagnosisInitial extends AiDiagnosisState {}

class AiDiagnosisLoading extends AiDiagnosisState {}

class AiDiagnosisSuccess extends AiDiagnosisState {
  final VisionAnalysis analysis;

  const AiDiagnosisSuccess({required this.analysis});

  @override
  List<Object> get props => [analysis];
}

class AiDiagnosisError extends AiDiagnosisState {
  final String message;

  const AiDiagnosisError({required this.message});

  @override
  List<Object> get props => [message];
}
