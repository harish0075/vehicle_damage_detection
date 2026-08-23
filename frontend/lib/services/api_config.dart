/// API Configuration
class ApiConfig {
  ApiConfig._();
  
  // Set this at build/run time. Example:
  // flutter build apk --dart-define=API_BASE_URL=https://your-api.onrender.com
  // The fallback is only for Android-emulator local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  
  // API Endpoints
  static const String detectDamage = '/detect-damage';
  static const String processInsurance = '/process-insurance';
  static const String generateBill = '/generate-bill';
  static const String submitClaim = '/claim';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
