import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flkit/create/starter_config.dart';
import 'package:flkit/create/starter_language.dart';
import 'package:flkit/create/starter_platform.dart';
import 'package:flkit/templates/template_locator.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class CreateCommand extends Command<void> {
  CreateCommand() {
    argParser.addOption(
      'template',
      allowed: const ['starter'],
      help: 'Generate a project from a preset template.',
    );
    argParser.addOption(
      'bundle-id',
      help: 'Bundle ID used for the generated Flutter project.',
    );
    argParser.addOption(
      'platforms',
      help:
          'Project targets to generate. Use mobile, desktop, web, or Flutter platforms.',
    );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project.';

  final Logger _logger = Logger();

  @override
  Future<void> run() async {
    final appName = argResults?.rest.firstOrNull;

    if (appName == null) {
      throw UsageException('Missing app name.', usage);
    }

    final template = argResults?['template'] as String?;
    final bundleId =
        argResults?['bundle-id'] as String? ??
        _logger.prompt('Bundle ID', defaultValue: 'com.example.app');
    final platforms = _resolvePlatforms(argResults?['platforms'] as String?);

    final config = template == 'starter'
        ? const StarterConfig(
            useRiverpod: true,
            useDio: true,
            languages: StarterLanguage.values,
          )
        : _promptCustomConfig();

    final created = await _runStep(
      message: 'Creating Flutter project',
      executable: 'flutter',
      arguments: [
        'create',
        appName,
        '--org',
        bundleId,
        '--platforms',
        platforms.map((platform) => platform.name).join(','),
      ],
      failureMessage: 'Flutter create failed',
      successMessage: 'Flutter project created',
    );

    if (!created) return;

    final brick = Brick.path(await resolveTemplatePath('starter'));
    final generator = await MasonGenerator.fromBrick(brick);

    final packageName = _toPackageName(appName);
    final languages = _normalizeLanguages(config.languages);

    await generator.generate(
      DirectoryGeneratorTarget(Directory(appName)),
      vars: {
        'package_name': packageName,
        'display_name': _toDisplayName(packageName),
        'use_riverpod': config.useRiverpod,
        'use_dio': config.useDio,
        'base_locale': StarterLanguage.en.code,
      },
    );

    _removeUnselectedTranslations(
      projectDirectory: Directory(appName),
      selectedLanguages: languages,
    );
    _ensureEnvironmentFiles(Directory(appName));
    _ensureEnvFilesAreIgnored(Directory(appName));

    final dependenciesInstalled = await _runStep(
      message: 'Installing starter dependencies',
      executable: 'flutter',
      arguments: ['pub', 'get'],
      workingDirectory: appName,
      failureMessage: 'flutter pub get failed',
      successMessage: 'Starter dependencies installed',
    );

    if (!dependenciesInstalled) return;

    final translationsGenerated = await _runStep(
      message: 'Generating translations',
      executable: 'dart',
      arguments: ['run', 'slang'],
      workingDirectory: appName,
      failureMessage: 'Slang generation failed',
      successMessage: 'Translations generated',
    );

    if (!translationsGenerated) return;

    _logger
      ..success('Done')
      ..info('')
      ..info('Next steps:')
      ..info('  cd $appName')
      ..info('  dart run build_runner build --delete-conflicting-outputs')
      ..info('  flutter run');
  }

  StarterConfig _promptCustomConfig() {
    final languages = _logger.chooseAny<StarterLanguage>(
      'Languages',
      choices: StarterLanguage.values,
      defaultValues: StarterLanguage.values,
      display: (language) => language.label,
    );

    return StarterConfig(
      useRiverpod: _logger.confirm(
        'Use Riverpod Generator?',
        defaultValue: true,
      ),
      useDio: _logger.confirm('Use Dio?', defaultValue: true),
      languages: languages,
    );
  }

  List<StarterPlatform> _resolvePlatforms(String? rawPlatforms) {
    if (rawPlatforms != null && rawPlatforms.trim().isNotEmpty) {
      return _normalizePlatforms(_parsePlatformInput(rawPlatforms));
    }

    final groups = _logger.chooseAny<StarterPlatformGroup>(
      'Project targets',
      choices: StarterPlatformGroup.values,
      defaultValues: const [StarterPlatformGroup.mobile],
      display: (group) => group.label,
    );

    return _normalizePlatforms(
      groups.isEmpty
          ? StarterPlatformGroup.mobile.platforms
          : groups.expand((group) => group.platforms),
    );
  }

  Iterable<StarterPlatform> _parsePlatformInput(String rawPlatforms) {
    return rawPlatforms
        .split(',')
        .map((platform) => platform.trim().toLowerCase())
        .where((platform) => platform.isNotEmpty)
        .expand((platform) {
          final group = StarterPlatformGroup.fromName(platform);
          if (group != null) return group.platforms;

          final starterPlatform = StarterPlatform.fromName(platform);
          if (starterPlatform != null) return [starterPlatform];

          throw UsageException(
            'Unknown platform "$platform". '
            'Use mobile, desktop, web, android, ios, linux, macos, or windows.',
            usage,
          );
        });
  }

  List<StarterPlatform> _normalizePlatforms(
    Iterable<StarterPlatform> platforms,
  ) {
    final normalized = platforms.toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return normalized.isEmpty
        ? StarterPlatformGroup.mobile.platforms
        : normalized;
  }

  List<StarterLanguage> _normalizeLanguages(List<StarterLanguage> languages) {
    final normalized = languages.isEmpty
        ? <StarterLanguage>[...StarterLanguage.values]
        : <StarterLanguage>{StarterLanguage.en, ...languages}.toList();

    normalized.sort((a, b) => a.index.compareTo(b.index));
    return normalized;
  }

  void _removeUnselectedTranslations({
    required Directory projectDirectory,
    required List<StarterLanguage> selectedLanguages,
  }) {
    final selectedCodes = selectedLanguages.map((language) => language.code);
    final i18nDirectory = Directory(p.join(projectDirectory.path, 'lib'));

    if (!i18nDirectory.existsSync()) return;

    for (final file in i18nDirectory.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.i18n.json')) continue;

      final fileName = p.basename(file.path);
      final locale = RegExp(r'_([a-z]{2})\.i18n\.json$').firstMatch(fileName);

      if (locale == null || selectedCodes.contains(locale.group(1))) {
        continue;
      }

      file.deleteSync();
    }
  }

  void _ensureEnvFilesAreIgnored(Directory projectDirectory) {
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

  void _ensureEnvironmentFiles(Directory projectDirectory) {
    const defaultEnvironment = 'API_BASE_URL=https://api.example.com\n';

    for (final fileName in ['.env', '.env.example']) {
      final file = File(p.join(projectDirectory.path, fileName));

      if (!file.existsSync()) {
        file.writeAsStringSync(defaultEnvironment);
      }
    }
  }

  String _toPackageName(String appName) {
    final packageName = p
        .basename(appName)
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return packageName.isEmpty ? 'sample_app' : packageName;
  }

  String _toDisplayName(String packageName) {
    return packageName
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<bool> _runStep({
    required String message,
    required String executable,
    required List<String> arguments,
    required String failureMessage,
    required String successMessage,
    String? workingDirectory,
  }) async {
    final progress = _logger.progress(message);
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      progress.fail(failureMessage);
      _logger.err(result.stderr.toString());
      return false;
    }

    progress.complete(successMessage);
    return true;
  }
}
