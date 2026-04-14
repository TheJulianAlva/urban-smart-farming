import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_diagnosis_event.dart';
import 'ai_diagnosis_state.dart';

/// Bloc para el flujo de Diagnóstico con IA (mock)
class AiDiagnosisBloc extends Bloc<AiDiagnosisEvent, AiDiagnosisState> {
  String _currentImagePath = '';

  AiDiagnosisBloc() : super(AiDiagnosisInitial()) {
    on<AiDiagnosisStarted>(_onStarted);
    on<ImageSelected>(_onImageSelected);
    on<AnalysisRequested>(_onAnalysisRequested);
    on<AnalysisReset>(_onAnalysisReset);
  }

  void _onStarted(AiDiagnosisStarted event, Emitter<AiDiagnosisState> emit) {
    emit(AiDiagnosisInitial());
  }

  void _onImageSelected(ImageSelected event, Emitter<AiDiagnosisState> emit) {
    _currentImagePath = event.imagePath;
    emit(AiDiagnosisImageSelected(event.imagePath));
  }

  Future<void> _onAnalysisRequested(
    AnalysisRequested event,
    Emitter<AiDiagnosisState> emit,
  ) async {
    emit(AiDiagnosisAnalyzing(_currentImagePath));

    // Simular tiempo de procesamiento de IA
    await Future.delayed(const Duration(milliseconds: 2500));

    // Resultado mock con información completa y descriptiva
    emit(
      AiDiagnosisResult(
        imagePath: _currentImagePath,
        problemName: 'Oídio (Erysiphales)',
        problemDescription:
            'Se ha detectado la presencia de oídio, una enfermedad fúngica '
            'muy común en plantas de huerto urbano. Se manifiesta como un '
            'polvo blanco-grisáceo sobre la superficie de las hojas, tallos '
            'y en ocasiones frutos. El hongo se alimenta de las células '
            'epidérmicas de la planta, debilitándola progresivamente y '
            'reduciendo su capacidad fotosintética. En etapas avanzadas, '
            'las hojas afectadas se deforman, se vuelven amarillas y pueden '
            'caer prematuramente, comprometiendo la producción del cultivo.',
        severity: 'Moderada',
        affectedArea: 'Hojas superiores y brotes jóvenes',
        recommendations: [
          'Retirar y desechar las hojas más afectadas para reducir la carga '
              'fúngica. No las deposites en la composta ya que las esporas '
              'pueden sobrevivir.',
          'Aplicar una solución fungicida a base de azufre o bicarbonato '
              'de sodio (1 cucharada por litro de agua con unas gotas de '
              'jabón neutro) cada 7 días durante 3 semanas.',
          'Mejorar la circulación de aire entre las plantas separándolas '
              'al menos 20-30 cm y podando el follaje denso interior.',
          'Regar temprano por la mañana y evitar mojar el follaje. '
              'El riego por goteo es ideal para prevenir la humedad '
              'excesiva en las hojas.',
          'Considerar aplicar extracto de ajo o aceite de neem como '
              'tratamiento orgánico complementario cada 10-14 días.',
        ],
        preventionTips: [
          'Mantener una humedad relativa por debajo del 70% en el entorno '
              'del cultivo.',
          'Asegurar buena ventilación y exposición solar directa de al '
              'menos 6 horas diarias.',
          'Rotar los cultivos cada temporada para evitar la acumulación '
              'de patógenos en el sustrato.',
          'Inspeccionar las plantas semanalmente para detectar signos '
              'tempranos de infección.',
        ],
      ),
    );
  }

  void _onAnalysisReset(AnalysisReset event, Emitter<AiDiagnosisState> emit) {
    _currentImagePath = '';
    emit(AiDiagnosisInitial());
  }
}
