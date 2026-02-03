import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../models/damage.dart';

class HealthRecordsProvider with ChangeNotifier {
  final List<HealthRecord> _records = [];

  List<HealthRecord> get records => List.unmodifiable(_records);
  int get recordCount => _records.length;
  bool get hasRecords => _records.isNotEmpty;

  // Sorted records (most recent first)
  List<HealthRecord> get sortedRecords {
    final sorted = List<HealthRecord>.from(_records);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // Total cost calculation
  double get totalCost {
    return _records
        .where((record) => record.cost != null)
        .fold(0.0, (sum, record) => sum + record.cost!);
  }

  // Recent records (last 30 days)
  List<HealthRecord> get recentRecords {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _records.where((record) => record.date.isAfter(thirtyDaysAgo)).toList();
  }

  // Damage frequency map
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

  // Most frequent damage type
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

  // Cost trend (simple percentage change year over year)
  double get costTrendPercentage {
    final now = DateTime.now();
    final thisYearStart = DateTime(now.year, 1, 1);
    final lastYearStart = DateTime(now.year - 1, 1, 1);
    final lastYearEnd = DateTime(now.year - 1, 12, 31);

    final thisYearCost = _records
        .where((r) => r.cost != null && r.date.isAfter(thisYearStart))
        .fold(0.0, (sum, r) => sum + r.cost!);

    final lastYearCost = _records
        .where((r) => 
            r.cost != null && 
            r.date.isAfter(lastYearStart) && 
            r.date.isBefore(lastYearEnd))
        .fold(0.0, (sum, r) => sum + r.cost!);

    if (lastYearCost == 0) return 0;
    return ((thisYearCost - lastYearCost) / lastYearCost) * 100;
  }

  // Cost data for charts (month by month for last 6 months)
  Map<String, double> get monthlyCostData {
    final data = <String, double>{};
    final now = DateTime.now();
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.month}/${month.year}';
      
      final monthCost = _records
          .where((r) => 
              r.cost != null &&
              r.date.year == month.year &&
              r.date.month == month.month)
          .fold(0.0, (sum, r) => sum + r.cost!);
      
      data[monthKey] = monthCost;
    }
    
    return data;
  }

  void addRecord(HealthRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void removeRecord(String id) {
    _records.removeWhere((record) => record.id == id);
    notifyListeners();
  }

  void clearAll() {
    _records.clear();
    notifyListeners();
  }

  // Add damage detection record
  void addDamageDetection(Damage damage, {String? imagePath}) {
    final record = HealthRecord.damage(
      damage: damage,
      imagePath: imagePath,
    );
    addRecord(record);
  }

  // Add claim record
  void addClaim(Damage damage, double cost, {String? imagePath}) {
    final record = HealthRecord.claim(
      damage: damage,
      cost: cost,
      imagePath: imagePath,
    );
    addRecord(record);
  }
}
