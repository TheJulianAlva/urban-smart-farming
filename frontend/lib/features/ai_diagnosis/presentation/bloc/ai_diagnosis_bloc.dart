import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/usecases/analyze_crop_image.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_event.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_state.dart';

class AiDiagnosisBloc extends Bloc<AiDiagnosisEvent, AiDiagnosisState> {
  final AnalyzeCropImage analyzeCropImage;

  AiDiagnosisBloc({required this.analyzeCropImage}) : super(AiDiagnosisInitial()) {
    on<AnalyzeImageEvent>(_onAnalyzeImageEvent);
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
