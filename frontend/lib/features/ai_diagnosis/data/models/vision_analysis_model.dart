import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';

class VisionAnalysisModel extends VisionAnalysis {
  const VisionAnalysisModel({
    required super.diagnosis,
    required super.suggestedTreatment,
    required super.confidencePercentage,
  });

  factory VisionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return VisionAnalysisModel(
      diagnosis: json['diagnosis'] ?? 'Sin diagnóstico',
      suggestedTreatment: json['suggested_treatment'] ?? 'Sin tratamiento sugerido',
      confidencePercentage: (json['confidence_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'suggested_treatment': suggestedTreatment,
      'confidence_percentage': confidencePercentage,
    };
  }
}
