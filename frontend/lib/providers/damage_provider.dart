import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DamageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  File? _selectedImage;
  List<Map<String, dynamic>> _detectedDamages = [];
  double _imageWidth = 0;
  double _imageHeight = 0;
  bool _isLoading = false;
  String? _error;

  File? get selectedImage => _selectedImage;
  List<Map<String, dynamic>> get detectedDamages => _detectedDamages;
  double get imageWidth => _imageWidth;
  double get imageHeight => _imageHeight;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDamages => _detectedDamages.isNotEmpty;

  void setSelectedImage(File? image) {
    _selectedImage = image;
    _detectedDamages = [];
    _imageWidth = 0;
    _imageHeight = 0;
    _error = null;
    notifyListeners();
  }

  Future<void> detectDamage() async {
    if (_selectedImage == null) {
      _error = 'Please select an image first';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.detectDamage(_selectedImage!);
      _detectedDamages = List<Map<String, dynamic>>.from(result['damages'] as List);
      _imageWidth = result['imageWidth'] as double;
      _imageHeight = result['imageHeight'] as double;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _detectedDamages = [];
      _imageWidth = 0;
      _imageHeight = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _detectedDamages = [];
    _imageWidth = 0;
    _imageHeight = 0;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
