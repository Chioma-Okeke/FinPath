class Resource {
  final String id;
  final String category;
  final String provider;
  final String title;
  final String description;
  final String typicalCost;
  final String whyItMatters;
  final List<String> whoNeedsIt;
  final String learnMoreUrl;
  final String actionKey;

  Resource({
    required this.id,
    required this.category,
    required this.provider,
    required this.title,
    required this.description,
    required this.typicalCost,
    required this.whyItMatters,
    required this.whoNeedsIt,
    required this.learnMoreUrl,
    required this.actionKey,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      provider: json['provider'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      typicalCost: json['typical_cost'] ?? '',
      whyItMatters: json['why_it_matters'] ?? '',
      whoNeedsIt: (json['who_needs_it'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      learnMoreUrl: json['learn_more_url'] ?? '',
      actionKey: json['action_key'] ?? '',
    );
  }
}
