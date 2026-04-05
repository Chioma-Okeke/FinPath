class OnboardingOption {
  final String value;
  final String labelEn;
  final String labelEs;
  final String? emoji;

  OnboardingOption({
    required this.value,
    required this.labelEn,
    required this.labelEs,
    this.emoji,
  });

  factory OnboardingOption.fromJson(Map<String, dynamic> json) {
    return OnboardingOption(
      value: json['value'] as String,
      labelEn: json['label_en'] as String,
      labelEs: json['label_es'] as String,
      emoji: json['emoji'] as String?,
    );
  }

  String label(String language) => language == 'es' ? labelEs : labelEn;

  String display(String language) {
    final text = label(language);
    if (emoji == null || emoji!.isEmpty) return text;
    return '$emoji  $text';
  }
}