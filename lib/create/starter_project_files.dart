import 'dart:io';

import 'package:hoshika_flkit/create/starter_language.dart';
import 'package:hoshika_flkit/utils/project_files.dart';
import 'package:path/path.dart' as p;

void removeUnselectedTranslations({
  required Directory projectDirectory,
  required List<StarterLanguage> selectedLanguages,
}) {
  final selectedCodes = selectedLanguages.map((language) => language.code);
  final libDirectory = Directory(p.join(projectDirectory.path, 'lib'));

  if (!libDirectory.existsSync()) return;

  for (final file in libDirectory.listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.i18n.json')) continue;

    final locale = translationLocalePattern.firstMatch(p.basename(file.path));

    if (locale == null || selectedCodes.contains(locale.group(1))) {
      continue;
    }

    file.deleteSync();
  }
}

void ensureEnvironmentFiles(Directory projectDirectory) {
  const defaultEnvironment = 'API_BASE_URL=https://api.example.com\n';

  for (final fileName in ['.env', '.env.example']) {
    final file = File(p.join(projectDirectory.path, fileName));

    if (!file.existsSync()) {
      file.writeAsStringSync(defaultEnvironment);
    }
  }
}

void ensureEnvFilesAreIgnored(Directory projectDirectory) {
  final gitignore = File(p.join(projectDirectory.path, '.gitignore'));
  const entries = ['.env', '.env.*', '!.env.example'];

  if (!gitignore.existsSync()) {
    gitignore.writeAsStringSync('${entries.join('\n')}\n');
    return;
  }

  final content = gitignore.readAsStringSync();
  final missingEntries = entries.where(
    (entry) => !RegExp(
      '^${RegExp.escape(entry)}\$',
      multiLine: true,
    ).hasMatch(content),
  );

  if (missingEntries.isEmpty) return;

  final buffer = StringBuffer(content);
  if (content.isNotEmpty && !content.endsWith('\n')) {
    buffer.writeln();
  }

  buffer.writeln();
  buffer.writeln('# Environment');
  for (final entry in missingEntries) {
    buffer.writeln(entry);
  }

  gitignore.writeAsStringSync(buffer.toString());
}
