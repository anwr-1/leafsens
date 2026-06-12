import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/prediction_result.dart';

class ApiService {
  ApiService._();

  static String get localBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000';
  }


  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isEmpty) return false;
    if (connectivityResult.length == 1 && connectivityResult.first == ConnectivityResult.none) return false;
    return true;
  }

  static Future<PredictionResult> predict(XFile imageFile) async {
    return await _predictOfflineLocal(imageFile);
  }


  static Future<PredictionResult> _predictOfflineLocal(XFile imageFile) async {
    final fileName = imageFile.name;
    final ext = fileName.split('.').last.toLowerCase();
    final mime = _mimeFromExt(ext);

    final bytes = await imageFile.readAsBytes();

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: DioMediaType.parse(mime),
      ),
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$localBaseUrl/predict',
        data: formData,
      );
      if (response.data == null) throw Exception('Empty response from server');
      return PredictionResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('$localBaseUrl/health');
      return response.data?['model_loaded'] == true;
    } catch (_) {
      return false;
    }
  }

  static String _mimeFromExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  static Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return Exception('أنت غير متصل بالإنترنت ولم نتمكن من الوصول للمحرك المحلي.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
