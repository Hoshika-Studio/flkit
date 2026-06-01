import 'starter_language.dart';

class StarterConfig {
  const StarterConfig({
    required this.useRiverpod,
    required this.useDio,
    required this.languages,
  });

  final bool useRiverpod;
  final bool useDio;
  final List<StarterLanguage> languages;
}
