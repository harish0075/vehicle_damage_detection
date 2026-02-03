import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/damage.dart';
import '../services/api_service.dart';

class DamageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  File? _selectedImage;
  List<Damage> _detectedDamages = [];
  bool _isLoading = false;
  String? _error;

  File? get selectedImage => _selectedImage;
  List<Damage> get detectedDamages => _detectedDamages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDamages => _detectedDamages.isNotEmpty;

  void setSelectedImage(File? image) {
    _selectedImage = image;
    _detectedDamages = [];
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
      _detectedDamages = await _apiService.detectDamage(_selectedImage!);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _detectedDamages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _detectedDamages = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
