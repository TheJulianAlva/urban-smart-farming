import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AiDiagnosisEvent extends Equatable {
  const AiDiagnosisEvent();

  @override
  List<Object> get props => [];
}

class AnalyzeImageEvent extends AiDiagnosisEvent {
  final File image;
  final String cropId;

  const AnalyzeImageEvent({required this.image, required this.cropId});

  @override
  List<Object> get props => [image, cropId];
}
