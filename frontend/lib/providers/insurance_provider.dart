import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/insurance.dart';
import '../services/api_service.dart';

class InsuranceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  File? _selectedPdf;
  Insurance? _insuranceInfo;
  bool _isLoading = false;
  String? _error;

  File? get selectedPdf => _selectedPdf;
  Insurance? get insuranceInfo => _insuranceInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInsurance => _insuranceInfo != null;

  void setSelectedPdf(File? pdf) {
    _selectedPdf = pdf;
    _insuranceInfo = null;
    _error = null;
    notifyListeners();
  }

  Future<void> processInsurance() async {
    if (_selectedPdf == null) {
      _error = 'Please select a PDF file first';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insuranceInfo = await _apiService.processInsurance(_selectedPdf!);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _insuranceInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedPdf = null;
    _insuranceInfo = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
