// Model classes for the /predict API response.

class TopPrediction {
  final String className;
  final double confidence;

  const TopPrediction({
    required this.className,
    required this.confidence,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      // The backend uses "class" as the key but that's a reserved Dart word —
      // the backend field is mapped from "class_name" in the Pydantic schema.
      className: (json['class_name'] ?? json['class'] ?? '') as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'class_name': className,
        'confidence': confidence,
      };
}

class PredictionResult {
  final String plant;
  final String disease;
  final bool isHealthy;
  final double confidence;
  final String rawClass;
  final List<TopPrediction> top3;

  const PredictionResult({
    required this.plant,
    required this.disease,
    required this.isHealthy,
    required this.confidence,
    required this.rawClass,
    required this.top3,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      plant: json['plant'] as String,
      disease: json['disease'] as String,
      isHealthy: json['is_healthy'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      rawClass: json['raw_class'] as String,
      top3: (json['top3'] as List<dynamic>)
          .map((e) => TopPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'plant': plant,
        'disease': disease,
        'is_healthy': isHealthy,
        'confidence': confidence,
        'raw_class': rawClass,
        'top3': top3.map((e) => e.toJson()).toList(),
      };

  /// Human-readable label shown in the UI.
  String get displayLabel => isHealthy ? '$plant – Healthy ✓' : '$plant – $disease';
}
