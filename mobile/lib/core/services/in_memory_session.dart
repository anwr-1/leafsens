import '../../models/prediction_result.dart';

class InMemorySession {
  InMemorySession._();

  static final List<Map<String, dynamic>> _scans = [];

  static void addScan(PredictionResult result, String imagePath) {
    _scans.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'plant': result.plant,
      'disease': result.disease,
      'isHealthy': result.isHealthy,
      'confidence': result.confidence,
      'rawClass': result.rawClass,
      'imagePath': imagePath,
      'created': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>> getAll() => List.unmodifiable(_scans);

  static void delete(String id) => _scans.removeWhere((e) => e['id'] == id);

  static void clear() => _scans.clear();
}
