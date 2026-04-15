import 'package:urban_smart_farming/features/ai_diagnosis/domain/entities/vision_analysis.dart';

class VisionAnalysisModel extends VisionAnalysis {
  const VisionAnalysisModel({
    required super.diagnosis,
    required super.suggestedTreatment,
    required super.confidencePercentage,
    required super.severity,
    required super.problemName,
    required super.affectedArea,
    required super.problemDescription,
    required super.recommendations,
    required super.preventionTips,
  });

  factory VisionAnalysisModel.fromJson(Map<String, dynamic> json) {
    final diagnosis = json['diagnosis'] as String? ?? 'Sin diagnóstico';
    final suggestedTreatment =
        json['suggested_treatment'] as String? ?? 'Sin tratamiento sugerido';
    final confidencePercentage =
        (json['confidence_percentage'] ?? 0.0).toDouble();

    final String severity;
    if (json['severity'] != null) {
      severity = json['severity'] as String;
    } else if (confidencePercentage >= 0.7) {
      severity = 'Alta';
    } else if (confidencePercentage >= 0.4) {
      severity = 'Moderada';
    } else {
      severity = 'Baja';
    }

    return VisionAnalysisModel(
      diagnosis: diagnosis,
      suggestedTreatment: suggestedTreatment,
      confidencePercentage: confidencePercentage,
      severity: severity,
      problemName: json['problem_name'] as String? ?? diagnosis,
      affectedArea: json['affected_area'] as String? ?? 'Planta completa',
      problemDescription: json['problem_description'] as String? ?? diagnosis,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [suggestedTreatment],
      preventionTips: (json['prevention_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'suggested_treatment': suggestedTreatment,
      'confidence_percentage': confidencePercentage,
      'severity': severity,
      'problem_name': problemName,
      'affected_area': affectedArea,
      'problem_description': problemDescription,
      'recommendations': recommendations,
      'prevention_tips': preventionTips,
    };
  }
}
