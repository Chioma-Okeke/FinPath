class ActionItem {
  final String id;
  final String key;
  final String title;
  final String description;
  final String educationCard;
  final String? productLink;
  final int priority;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.educationCard,
    this.productLink,
    required this.priority,
    this.isCompleted = false,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    // backend uses 'key' (string) as identifier, no numeric id
    final keyStr = json['key'] as String? ?? '';

    return ActionItem(
      id: keyStr,
      key: keyStr,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      educationCard: json['education_card'] ?? '',
      productLink: json['statefarm_product'] ?? json['product_link'],
      priority: json['priority'] ?? 1,
      isCompleted: json['completed'] ?? json['is_completed'] ?? false,
    );
  }
}
