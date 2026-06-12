import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final geminiApiKey = 'AQ.Ab8RN6JPrBya6gVrIRK9HOD-I4yLttzsvT3dgGW5p2y4MywF8Q';
  final geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

  // Create a dummy image (1x1 transparent png)
  final base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

  final payload = {
    "contents": [
      {
        "parts": [
          {
            "text": "Identify the plant"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": base64Image
            }
          }
        ]
      }
    ]
  };

  try {
    final response = await dio.post(
      geminiUrl,
      options: Options(headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': geminiApiKey,
      }),
      data: payload,
    );
    print('SUCCESS: ${response.statusCode}');
    print(response.data);
  } on DioException catch (e) {
    print('DIO ERROR: ${e.response?.statusCode}');
    print(e.response?.data);
  } catch (e) {
    print('ERROR: $e');
  }
}
