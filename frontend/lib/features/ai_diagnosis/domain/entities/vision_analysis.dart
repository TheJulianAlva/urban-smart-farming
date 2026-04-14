import 'package:equatable/equatable.dart';

class VisionAnalysis extends Equatable {
  final String diagnosis;
  final String suggestedTreatment;
  final double confidencePercentage;

  const VisionAnalysis({
    required this.diagnosis,
    required this.suggestedTreatment,
    required this.confidencePercentage,
  });

  @override
  List<Object?> get props => [diagnosis, suggestedTreatment, confidencePercentage];
}
