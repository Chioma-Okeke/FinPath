class Snapshot {
  final int riskScore;
  final String riskLevel;
  final String biggestRisk;
  final Map<String, bool> coverageStatus;

  Snapshot({
    required this.riskScore,
    required this.riskLevel,
    required this.biggestRisk,
    required this.coverageStatus,
  });

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    return Snapshot(
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'Low',
      biggestRisk: json['biggest_risk'] ?? '',
      coverageStatus: Map<String, bool>.from(json['coverage_status'] ?? {}),
    );
  }
}
