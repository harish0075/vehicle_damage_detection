import 'dart:io';

class DamageDetection {
  final String id;
  final List<Map<String, dynamic>> damages; // List of detected damages
  final String? imagePath; // Local path to the image
  final DateTime timestamp;
  final double imageWidth;
  final double imageHeight;

  DamageDetection({
    required this.id,
    required this.damages,
    this.imagePath,
    required this.timestamp,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  factory DamageDetection.fromJson(Map<String, dynamic> json) {
    return DamageDetection(
      id: json['id'] as String? ?? '',
      damages: (json['damages'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      imagePath: json['imagePath'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      imageWidth: (json['imageWidth'] as num?)?.toDouble() ?? 0,
      imageHeight: (json['imageHeight'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'damages': damages,
      if (imagePath != null) 'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  int get damageCount => damages.length;

  File? get imageFile =>
      imagePath != null ? File(imagePath!) : null;
}
