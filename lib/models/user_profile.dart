class UserProfile {
  final int id;
  final String name;
  final String language; // 'en' or 'es'
  final String employmentType;
  final String incomeStability;
  final bool hasAutoInsurance;
  final bool hasHealthInsurance;
  final bool hasRentersInsurance;
  final bool isGigWorker;
  final int riskScore;
  final String riskLevel; // 'Low', 'Medium', 'High', 'Critical'

  UserProfile({
    required this.id,
    required this.name,
    required this.language,
    required this.employmentType,
    required this.incomeStability,
    required this.hasAutoInsurance,
    required this.hasHealthInsurance,
    required this.hasRentersInsurance,
    required this.isGigWorker,
    required this.riskScore,
    required this.riskLevel,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      language: json['language'] ?? 'en',
      employmentType: json['employment_type'] ?? '',
      incomeStability: json['income_stability'] ?? '',
      hasAutoInsurance: json['has_auto_insurance'] ?? false,
      hasHealthInsurance: json['has_health_insurance'] ?? false,
      hasRentersInsurance: json['has_renters_insurance'] ?? false,
      isGigWorker: json['is_gig_worker'] ?? false,
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'Low',
    );
  }
}
