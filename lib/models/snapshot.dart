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
    // coverage comes as {"auto_insurance": {"covered": false, "label": "Auto Insurance"}, ...}
    final rawCoverage = (json['coverage'] ?? json['coverage_status']) as Map<String, dynamic>?;
    final coverage = <String, bool>{};
    rawCoverage?.forEach((key, value) {
      if (value is bool) {
        coverage[key] = value;
      } else if (value is Map) {
        final label = value['label'] as String? ?? key;
        coverage[label] = value['covered'] as bool? ?? false;
      }
    });

    // normalize risk_level to title case
    final rawLevel = (json['risk_level'] ?? 'Low') as String;
    final riskLevel = rawLevel.isEmpty
        ? 'Low'
        : rawLevel[0].toUpperCase() + rawLevel.substring(1).toLowerCase();

    return Snapshot(
      riskScore: json['risk_score'] ?? 0,
      riskLevel: riskLevel,
      biggestRisk: json['biggest_risk'] ?? '',
      coverageStatus: coverage,
    );
  }
}
