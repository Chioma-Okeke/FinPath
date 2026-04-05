class ActionItem {
  final String id;
  final String key;
  final String title;
  final String description;
  final String educationCard;
  final String? productLink;
  final String resourceId;
  final int priority;
  bool isCompleted;
  final DateTime? completedAt;

  ActionItem({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.educationCard,
    this.productLink,
    required this.resourceId,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    // backend uses 'key' (string) as identifier, no numeric id
    final keyStr = json['key'] as String? ?? '';

    final completedAtRaw = json['completed_at'] as String?;
    DateTime? completedAt;
    if (completedAtRaw != null) {
      completedAt = DateTime.tryParse(completedAtRaw);
    }

    return ActionItem(
      id: keyStr,
      key: keyStr,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      educationCard: json['education_card'] ?? '',
      productLink: json['statefarm_product'] ?? json['product_link'],
      priority: json['priority'] ?? 1,
      resourceId: json['resource_id'] ?? '',
      isCompleted: json['completed'] ?? json['is_completed'] ?? false,
      completedAt: completedAt,
    );
  }
}
