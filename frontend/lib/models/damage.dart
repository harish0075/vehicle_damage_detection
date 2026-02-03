class Damage {
  final String type;
  final String severity;
  final double confidence;
  final String? location;

  Damage({
    required this.type,
    required this.severity,
    required this.confidence,
    this.location,
  });

  factory Damage.fromJson(Map<String, dynamic> json) {
    return Damage(
      type: json['type'] as String? ?? 'Unknown',
      severity: json['severity'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'confidence': confidence,
      if (location != null) 'location': location,
    };
  }

  String get severityLevel {
    final lower = severity.toLowerCase();
    if (lower.contains('critical')) return 'Critical';
    if (lower.contains('severe')) return 'Severe';
    if (lower.contains('moderate')) return 'Moderate';
    return 'Minor';
  }

  @override
  String toString() => 'Damage(type: $type, severity: $severity, confidence: $confidence)';
}
