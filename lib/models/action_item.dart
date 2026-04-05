class ActionItem {
  final int id;
  final String title;
  final String description;
  final String educationCard;
  final String? productLink;
  final int priority;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.educationCard,
    this.productLink,
    required this.priority,
    this.isCompleted = false,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      educationCard: json['education_card'] ?? '',
      productLink: json['product_link'],
      priority: json['priority'] ?? 1,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
