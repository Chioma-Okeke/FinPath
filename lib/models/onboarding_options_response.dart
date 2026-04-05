// lib/models/onboarding_options_response.dart
import 'onboarding_option.dart';

class OnboardingOptionsResponse {
  final List<OnboardingOption> lifeSituations;
  final List<OnboardingOption> incomeSources;
  final List<OnboardingOption> entryRoutes;
  final List<OnboardingOption> housingTypes;

  OnboardingOptionsResponse({
    required this.lifeSituations,
    required this.incomeSources,
    required this.entryRoutes,
    required this.housingTypes,
  });

  factory OnboardingOptionsResponse.fromJson(Map<String, dynamic> json) {
    List<OnboardingOption> parse(String key) {
      return (json[key] as List<dynamic>)
          .map((e) => OnboardingOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OnboardingOptionsResponse(
      lifeSituations: parse('life_situations'),
      incomeSources: parse('income_sources'),
      entryRoutes: parse('entry_routes'),
      housingTypes: parse('housing_types'),
    );
  }
}