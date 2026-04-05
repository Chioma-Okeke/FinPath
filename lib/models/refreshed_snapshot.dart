// lib/models/refreshed_snapshot.dart

import 'action_item.dart';

class RefreshedSnapshot {
  final int riskScore;
  final String riskLevel;
  final String biggestRisk;
  final String aiInsight;
  final List<ActionItem> actions;
  final String poweredBy;

  RefreshedSnapshot({
    required this.riskScore,
    required this.riskLevel,
    required this.biggestRisk,
    required this.aiInsight,
    required this.actions,
    required this.poweredBy,
  });

  factory RefreshedSnapshot.fromJson(Map<String, dynamic> json) {
    return RefreshedSnapshot(
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? '',
      biggestRisk: json['biggest_risk'] ?? '',
      aiInsight: json['ai_insight'] ?? '',
      actions: (json['actions'] as List<dynamic>? ?? [])
          .map((a) => ActionItem.fromJson(a as Map<String, dynamic>))
          .toList(),
      poweredBy: json['powered_by'] ?? '',
    );
  }
}