import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final translationLocalePattern = RegExp(r'_([a-z]{2})\.i18n\.json$');

String? readPackageName(File pubspec) {
  final yaml = loadYaml(pubspec.readAsStringSync());

  if (yaml is! YamlMap || yaml['name'] is! String) return null;

  return yaml['name'] as String;
}

List<String> detectTranslationLanguages(Directory projectDirectory) {
  final libDirectory = Directory(p.join(projectDirectory.path, 'lib'));
  if (!libDirectory.existsSync()) return const [];

  final languages = <String>{};

  for (final file in libDirectory.listSync(recursive: true)) {
    if (file is! File) continue;

    final match = translationLocalePattern.firstMatch(p.basename(file.path));
    if (match != null) {
      languages.add(match.group(1)!);
    }
  }

  return languages.toList()..sort();
}
