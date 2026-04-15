import 'package:equatable/equatable.dart';

class VisionAnalysis extends Equatable {
  final String diagnosis;
  final String suggestedTreatment;
  final double confidencePercentage;
  final String severity;
  final String problemName;
  final String affectedArea;
  final String problemDescription;
  final List<String> recommendations;
  final List<String> preventionTips;

  const VisionAnalysis({
    required this.diagnosis,
    required this.suggestedTreatment,
    required this.confidencePercentage,
    required this.severity,
    required this.problemName,
    required this.affectedArea,
    required this.problemDescription,
    required this.recommendations,
    required this.preventionTips,
  });

  @override
  List<Object?> get props => [
        diagnosis,
        suggestedTreatment,
        confidencePercentage,
        severity,
        problemName,
        affectedArea,
        problemDescription,
        recommendations,
        preventionTips,
      ];
}
