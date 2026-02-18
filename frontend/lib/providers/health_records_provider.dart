import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_record.dart';
import '../models/damage.dart';

class HealthRecordsProvider with ChangeNotifier {
  final List<HealthRecord> _records = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HealthRecord> get records => List.unmodifiable(_records);
  int get recordCount => _records.length;
  bool get hasRecords => _records.isNotEmpty;

  /// 🔥 LOAD records from Firestore (per user)
  Future<void> loadRecords() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .orderBy('date', descending: true)
          .get();

      _records.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        _records.add(HealthRecord.fromJson(data));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading records: $e');
    }
  }

  /// 🔥 SAVE record to Firestore + local state
  Future<void> addRecord(HealthRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .doc(record.id)
          .set(record.toJson());

      // Save locally (for instant UI update)
      _records.add(record);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving record: $e');
    }
  }

  Future<void> removeRecord(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .doc(id)
          .delete();

      _records.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting record: $e');
    }
  }

  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      _records.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing records: $e');
    }
  }

  /// 🔥 Add damage detection record (YOUR MAIN FEATURE)
  Future<void> addDamageDetection(Damage damage, {String? imagePath}) async {
    final record = HealthRecord.damage(
      damage: damage,
      imagePath: imagePath,
    );
    await addRecord(record);
  }

  /// (Optional - not needed if you removed claims)
  Future<void> addClaim(Damage damage, double cost, {String? imagePath}) async {
    final record = HealthRecord.claim(
      damage: damage,
      cost: cost,
      imagePath: imagePath,
    );
    await addRecord(record);
  }

  // ================= ANALYTICS (UNCHANGED - YOUR CODE) =================

  List<HealthRecord> get sortedRecords {
    final sorted = List<HealthRecord>.from(_records);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  double get totalCost {
    return _records
        .where((record) => record.cost != null)
        .fold(0.0, (sum, record) => sum + record.cost!);
  }

  List<HealthRecord> get recentRecords {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _records
        .where((record) => record.date.isAfter(thirtyDaysAgo))
        .toList();
  }

  Map<String, int> get damageFrequency {
    final frequency = <String, int>{};
    for (final record in _records) {
      if (record.damage != null) {
        final type = record.damage!.type;
        frequency[type] = (frequency[type] ?? 0) + 1;
      }
    }
    return frequency;
  }

  String get mostFrequentDamage {
    if (damageFrequency.isEmpty) return 'No damages recorded';

    var maxCount = 0;
    var maxType = 'None';

    damageFrequency.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        maxType = type;
      }
    });

    return maxType;
  }
}
