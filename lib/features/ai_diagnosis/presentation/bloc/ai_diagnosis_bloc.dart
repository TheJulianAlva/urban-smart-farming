import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_diagnosis_event.dart';
import 'ai_diagnosis_state.dart';

/// Bloc placeholder para diagnóstico con IA
class AiDiagnosisBloc extends Bloc<AiDiagnosisEvent, AiDiagnosisState> {
  AiDiagnosisBloc() : super(AiDiagnosisInitial()) {
    on<AiDiagnosisStarted>(_onStarted);
  }

  void _onStarted(
    AiDiagnosisStarted event,
    Emitter<AiDiagnosisState> emit,
  ) {
    // Placeholder - sin lógica real
    emit(AiDiagnosisInitial());
  }
}
