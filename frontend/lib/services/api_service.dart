import 'dart:io';
import 'package:dio/dio.dart';
import '../models/damage.dart';
import '../models/insurance.dart';
import '../models/bill.dart';
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

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Detect damage from vehicle image
  /// POST /detect-damage
  Future<List<Damage>> detectDamage(File imageFile) async {
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

      final damages = (response.data['damages'] as List)
          .map((json) => Damage.fromJson(json as Map<String, dynamic>))
          .toList();

      return damages;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Process insurance document (PDF)
  /// POST /process-insurance
  Future<Insurance> processInsurance(File pdfFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConfig.processInsurance,
        data: formData,
      );

      return Insurance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate bill from damages and insurance
  /// POST /generate-bill
  Future<Bill> generateBill(List<Damage> damages, Insurance insurance) async {
    try {
      final response = await _dio.post(
        ApiConfig.generateBill,
        data: {
          'damages': damages.map((d) => d.toJson()).toList(),
          'insurance': insurance.toJson(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return Bill.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit full claim with vehicle image and insurance document
  /// POST /claim
  Future<Map<String, dynamic>> submitClaim(
    File vehicleImage,
    File insuranceDoc,
  ) async {
    try {
      final formData = FormData.fromMap({
        'vehicle_image': await MultipartFile.fromFile(
          vehicleImage.path,
          filename: vehicleImage.path.split('/').last,
        ),
        'insurance_doc': await MultipartFile.fromFile(
          insuranceDoc.path,
          filename: insuranceDoc.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConfig.submitClaim,
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      
      return {
        'damages': (data['damages'] as List)
            .map((json) => Damage.fromJson(json as Map<String, dynamic>))
            .toList(),
        'policy': Insurance.fromJson(data['policy'] as Map<String, dynamic>),
        'bill': Bill.fromJson(data['bill'] as Map<String, dynamic>),
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
      return 'Cannot connect to server. Please ensure the backend is running.';
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
