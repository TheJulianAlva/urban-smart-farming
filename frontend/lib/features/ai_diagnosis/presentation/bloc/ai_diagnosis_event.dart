import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AiDiagnosisEvent extends Equatable {
  const AiDiagnosisEvent();

  @override
  List<Object> get props => [];
}

/// El usuario seleccionó una imagen de la galería.
class ImageSelected extends AiDiagnosisEvent {
  final String imagePath;

  const ImageSelected(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// El usuario solicitó analizar la imagen seleccionada.
class AnalysisRequested extends AiDiagnosisEvent {
  const AnalysisRequested();
}

/// El usuario reinició el flujo de diagnóstico.
class AnalysisReset extends AiDiagnosisEvent {
  const AnalysisReset();
}

/// Evento de análisis con imagen y cropId explícitos (uso programático).
class AnalyzeImageEvent extends AiDiagnosisEvent {
  final File image;
  final String cropId;

  const AnalyzeImageEvent({required this.image, required this.cropId});

  @override
  List<Object> get props => [image, cropId];
}
