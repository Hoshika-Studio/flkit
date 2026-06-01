enum StarterLanguage {
  en('en', 'English (en)'),
  fr('fr', 'French (fr)');

  const StarterLanguage(this.code, this.label);

  final String code;
  final String label;
}
