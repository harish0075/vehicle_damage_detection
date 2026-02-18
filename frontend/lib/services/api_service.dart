import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Detect damage from vehicle image
  /// Returns detection result with damages, image dimensions
  Future<Map<String, dynamic>> detectDamage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConfig.detectDamage,
        data: formData,
      );

      // Return full response including damages and image dimensions
      return {
        'damages': response.data['damages'] as List,
        'imageWidth': (response.data['image_width'] as num?)?.toDouble() ?? 0.0,
        'imageHeight': (response.data['image_height'] as num?)?.toDouble() ?? 0.0,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please ensure the backend is running at ${ApiConfig.baseUrl}';
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 404) {
        return 'API endpoint not found.';
      } else if (statusCode == 500) {
        return 'Server error. Please try again later.';
      } else if (statusCode == 422) {
        return 'Invalid data format. Please check your input.';
      }
      return 'Error: ${e.response!.statusMessage}';
    }

    return 'An unexpected error occurred: ${e.message}';
  }
}
