import 'damage.dart';

class HealthRecord {
  final String id;
  final DateTime date;
  final String type; // "damage", "repair", "claim"
  final String status; // "Detected", "Repaired", "Claimed"
  final Damage? damage;
  final double? cost;
  final String? description;
  final String? imagePath;

  HealthRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.status,
    this.damage,
    this.cost,
    this.description,
    this.imagePath,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
      damage: json['damage'] != null 
          ? Damage.fromJson(json['damage'] as Map<String, dynamic>)
          : null,
      cost: (json['cost'] as num?)?.toDouble(),
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'status': status,
      if (damage != null) 'damage': damage!.toJson(),
      if (cost != null) 'cost': cost,
      if (description != null) 'description': description,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }

  factory HealthRecord.damage({
    required Damage damage,
    String? imagePath,
  }) {
    return HealthRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'damage',
      status: 'Detected',
      damage: damage,
      description: '${damage.type} detected',
      imagePath: imagePath,
    );
  }

  factory HealthRecord.claim({
    required Damage damage,
    required double cost,
    String? imagePath,
  }) {
    return HealthRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'claim',
      status: 'Claimed',
      damage: damage,
      cost: cost,
      description: 'Insurance claim for ${damage.type}',
      imagePath: imagePath,
    );
  }

  @override
  String toString() => 'HealthRecord(type: $type, status: $status, date: $date)';
}
