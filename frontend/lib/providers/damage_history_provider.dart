import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/damage_detection.dart';
import '../services/firestore_service.dart';

class DamageHistoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final List<DamageDetection> _detections = [];
  StreamSubscription<List<Map<String, dynamic>>>? _detectionSubscription;

  List<DamageDetection> get detections => List.unmodifiable(_detections);
  int get detectionCount => _detections.length;
  bool get hasDetections => _detections.isNotEmpty;

  /// Load detection history from Firestore (stream-based, real-time updates)
  void loadDetections() {
    _detectionSubscription?.cancel();
    
    _detectionSubscription = _firestoreService.loadDamageDetections().listen(
      (detectionMaps) {
        _detections.clear();
        for (final map in detectionMaps) {
          _detections.add(DamageDetection.fromJson(map));
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading detections: $error');
      },
    );
  }

  /// Save a new damage detection to Firestore
  Future<void> saveDetection({
    required List<Map<String, dynamic>> damages,
    required String? imagePath,
    required double imageWidth,
    required double imageHeight,
  }) async {
    // Don't catch - let errors bubble up to UI
    await _firestoreService.saveDamageDetection(
      damages: damages,
      imagePath: imagePath,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    // Stream will automatically update the list
  }

  /// Delete a detection
  Future<void> deleteDetection(String detectionId) async {
    // Don't catch - let errors bubble up to UI
    await _firestoreService.deleteDetection(detectionId);
    // Stream will automatically update the list
  }

  /// Get recent detections (last 30 days)
  List<DamageDetection> get recentDetections {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _detections
        .where((detection) => detection.timestamp.isAfter(thirtyDaysAgo))
        .toList();
  }

  /// Total number of damages across all detections
  int get totalDamagesDetected {
    return _detections.fold(0, (sum, detection) => sum + detection.damageCount);
  }

  @override
  void dispose() {
    _detectionSubscription?.cancel();
    super.dispose();
  }
}
