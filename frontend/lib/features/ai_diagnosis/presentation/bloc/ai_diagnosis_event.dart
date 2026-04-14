/// Eventos del BLoC de Diagnóstico con IA
abstract class AiDiagnosisEvent {}

/// Evento inicial
class AiDiagnosisStarted extends AiDiagnosisEvent {}

/// El usuario seleccionó una imagen de la galería
class ImageSelected extends AiDiagnosisEvent {
  final String imagePath;
  ImageSelected(this.imagePath);
}

/// El usuario solicita iniciar el análisis de la imagen
class AnalysisRequested extends AiDiagnosisEvent {}

/// El usuario quiere reiniciar el flujo para un nuevo diagnóstico
class AnalysisReset extends AiDiagnosisEvent {}
