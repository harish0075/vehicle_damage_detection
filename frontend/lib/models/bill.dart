class Bill {
  final double partsCost;
  final double laborCost;
  final double totalCost;
  final double insuranceCovered;
  final double userPayable;

  Bill({
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.insuranceCovered,
    required this.userPayable,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      partsCost: (json['partsCost'] as num?)?.toDouble() ?? 
                 (json['parts_cost'] as num?)?.toDouble() ?? 0.0,
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 
                 (json['labor_cost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 
                 (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      insuranceCovered: (json['insuranceCovered'] as num?)?.toDouble() ?? 
                        (json['insurance_covered'] as num?)?.toDouble() ?? 0.0,
      userPayable: (json['userPayable'] as num?)?.toDouble() ?? 
                   (json['user_payable'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partsCost': partsCost,
      'laborCost': laborCost,
      'totalCost': totalCost,
      'insuranceCovered': insuranceCovered,
      'userPayable': userPayable,
    };
  }

  double get coveragePercentage {
    if (totalCost == 0) return 0;
    return (insuranceCovered / totalCost) * 100;
  }

  @override
  String toString() => 'Bill(total: ₹$totalCost, payable: ₹$userPayable)';
}
