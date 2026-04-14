/// Estados del BLoC de Diagnóstico con IA
abstract class AiDiagnosisState {}

/// Estado inicial — sin imagen seleccionada
class AiDiagnosisInitial extends AiDiagnosisState {}

/// Imagen seleccionada, lista para analizar
class AiDiagnosisImageSelected extends AiDiagnosisState {
  final String imagePath;
  AiDiagnosisImageSelected(this.imagePath);
}

/// Simulando análisis de la imagen
class AiDiagnosisAnalyzing extends AiDiagnosisState {
  final String imagePath;
  AiDiagnosisAnalyzing(this.imagePath);
}

/// Resultado del análisis mock
class AiDiagnosisResult extends AiDiagnosisState {
  final String imagePath;
  final String problemName;
  final String problemDescription;
  final String severity;
  final String affectedArea;
  final List<String> recommendations;
  final List<String> preventionTips;

  AiDiagnosisResult({
    required this.imagePath,
    required this.problemName,
    required this.problemDescription,
    required this.severity,
    required this.affectedArea,
    required this.recommendations,
    required this.preventionTips,
  });
}
