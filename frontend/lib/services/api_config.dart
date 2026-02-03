/// API Configuration
class ApiConfig {
  ApiConfig._();
  
  // TODO: Update this to match your FastAPI server URL
  // For local development: 'http://10.0.2.2:8000' (Android emulator)
  // For local development: 'http://localhost:8000' (iOS simulator/web)
  // For production: 'https://your-api-domain.com'
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // API Endpoints
  static const String detectDamage = '/detect-damage';
  static const String processInsurance = '/process-insurance';
  static const String generateBill = '/generate-bill';
  static const String submitClaim = '/claim';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
