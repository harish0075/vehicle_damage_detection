class Damage {
  final String type;
  final String severity;
  final double confidence;
  final String? location;
  final List<double>? bbox; // [x, y, width, height] in pixels
  final String? imagePath; // Path to the image for this damage
  final DateTime? timestamp; // When the damage was detected

  Damage({
    required this.type,
    required this.severity,
    required this.confidence,
    this.location,
    this.bbox,
    this.imagePath,
    this.timestamp,
  });

  factory Damage.fromJson(Map<String, dynamic> json) {
    return Damage(
      type: json['type'] as String? ?? 'Unknown',
      severity: json['severity'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String?,
      bbox: json['bbox'] != null 
          ? (json['bbox'] as List).map((e) => (e as num).toDouble()).toList()
          : null,
      imagePath: json['imagePath'] as String?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'confidence': confidence,
      if (location != null) 'location': location,
      if (bbox != null) 'bbox': bbox,
      if (imagePath != null) 'imagePath': imagePath,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  String get severityLevel {
    final lower = severity.toLowerCase();
    if (lower.contains('critical')) return 'Critical';
    if (lower.contains('severe')) return 'Severe';
    if (lower.contains('moderate')) return 'Moderate';
    return 'Minor';
  }

  /// Get normalized bbox coordinates (0.0 to 1.0) for rendering
  List<double>? getNormalizedBbox(double imageWidth, double imageHeight) {
    if (bbox == null || bbox!.length != 4) return null;
    return [
      bbox![0] / imageWidth,  // x
      bbox![1] / imageHeight, // y
      bbox![2] / imageWidth,  // width
      bbox![3] / imageHeight, // height
    ];
  }

  @override
  String toString() => 'Damage(type: $type, severity: $severity, confidence: $confidence, bbox: $bbox)';
}
