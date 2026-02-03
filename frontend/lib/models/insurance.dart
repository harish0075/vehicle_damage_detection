class Insurance {
  final String provider;
  final String policyNumber;
  final double coverage;
  final DateTime expiryDate;
  final double claimLimit;

  Insurance({
    required this.provider,
    required this.policyNumber,
    required this.coverage,
    required this.expiryDate,
    required this.claimLimit,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      provider: json['provider'] as String? ?? 'Unknown Provider',
      policyNumber: json['policyNumber'] as String? ?? json['policy_number'] as String? ?? 'N/A',
      coverage: (json['coverage'] as num?)?.toDouble() ?? 0.0,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String)
          : (json['expiry_date'] != null 
              ? DateTime.parse(json['expiry_date'] as String)
              : DateTime.now()),
      claimLimit: (json['claimLimit'] as num?)?.toDouble() ?? 
                  (json['claim_limit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'policyNumber': policyNumber,
      'coverage': coverage,
      'expiryDate': expiryDate.toIso8601String(),
      'claimLimit': claimLimit,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  @override
  String toString() => 'Insurance(provider: $provider, policy: $policyNumber)';
}
