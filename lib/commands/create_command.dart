import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
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
        ? const _StarterConfig(
            useRiverpod: true,
            useDio: true,
            languages: StarterLanguage.values,
          )
        : _promptCustomConfig();

    final progress = _logger.progress('Creating Flutter project');

    final result = await Process.run('flutter', [
      'create',
      appName,
      '--org',
      bundleId,
      '--platforms',
      platforms.map((platform) => platform.name).join(','),
    ], runInShell: true);

    if (result.exitCode != 0) {
      progress.fail('Flutter create failed');
      _logger.err(result.stderr.toString());
      return;
    }

    progress.complete('Flutter project created');

    final brick = Brick.path(await _brickPath('starter'));
    final generator = await MasonGenerator.fromBrick(brick);

    final packageName = _toPackageName(appName);
    final languages = _normalizeLanguages(config.languages);

    await generator.generate(
      DirectoryGeneratorTarget(Directory(appName)),
      vars: {
        'app_name': packageName,
        'package_name': packageName,
        'display_name': _toDisplayName(packageName),
        'bundle_id': bundleId,
        'use_riverpod': config.useRiverpod,
        'use_dio': config.useDio,
        'languages': languages.map((language) => language.code).toList(),
        'base_locale': StarterLanguage.en.code,
        'use_en': languages.contains(StarterLanguage.en),
        'use_fr': languages.contains(StarterLanguage.fr),
      },
    );

    _removeUnselectedTranslations(
      projectDirectory: Directory(appName),
      selectedLanguages: languages,
    );

    final pubGetProgress = _logger.progress('Installing starter dependencies');
    final pubGetResult = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: appName,
      runInShell: true,
    );

    if (pubGetResult.exitCode != 0) {
      pubGetProgress.fail('flutter pub get failed');
      _logger.err(pubGetResult.stderr.toString());
      return;
    }

    pubGetProgress.complete('Starter dependencies installed');

    final slangProgress = _logger.progress('Generating translations');
    final slangResult = await Process.run(
      'dart',
      ['run', 'slang'],
      workingDirectory: appName,
      runInShell: true,
    );

    if (slangResult.exitCode != 0) {
      slangProgress.fail('Slang generation failed');
      _logger.err(slangResult.stderr.toString());
      return;
    }

    slangProgress.complete('Translations generated');

    _logger.success('Done');
  }

  _StarterConfig _promptCustomConfig() {
    final languages = _logger.chooseAny<StarterLanguage>(
      'Languages',
      choices: StarterLanguage.values,
      defaultValues: StarterLanguage.values,
      display: (language) => language.label,
    );

    return _StarterConfig(
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

  Future<String> _brickPath(String name) async {
    final packageUri = await Isolate.resolvePackageUri(
      Uri.parse('package:flkit/flkit.dart'),
    );

    if (packageUri == null) {
      throw StateError('Unable to resolve the FLKit package location.');
    }

    final packageRoot = p.dirname(p.dirname(packageUri.toFilePath()));
    return p.join(packageRoot, 'bricks', name);
  }
}

enum StarterLanguage {
  en('en', 'English (en)'),
  fr('fr', 'French (fr)');

  const StarterLanguage(this.code, this.label);

  final String code;
  final String label;
}

enum StarterPlatform {
  android('android'),
  ios('ios'),
  web('web'),
  linux('linux'),
  macos('macos'),
  windows('windows');

  const StarterPlatform(this.name);

  final String name;

  static StarterPlatform? fromName(String name) {
    for (final platform in values) {
      if (platform.name == name) return platform;
    }

    return null;
  }
}

enum StarterPlatformGroup {
  mobile('mobile', 'Mobile (Android + iOS)', [
    StarterPlatform.android,
    StarterPlatform.ios,
  ]),
  desktop('desktop', 'Desktop (Linux + macOS + Windows)', [
    StarterPlatform.linux,
    StarterPlatform.macos,
    StarterPlatform.windows,
  ]),
  web('web', 'Web', [StarterPlatform.web]);

  const StarterPlatformGroup(this.name, this.label, this.platforms);

  final String name;
  final String label;
  final List<StarterPlatform> platforms;

  static StarterPlatformGroup? fromName(String name) {
    for (final group in values) {
      if (group.name == name) return group;
    }

    return null;
  }
}

class _StarterConfig {
  const _StarterConfig({
    required this.useRiverpod,
    required this.useDio,
    required this.languages,
  });

  final bool useRiverpod;
  final bool useDio;
  final List<StarterLanguage> languages;
}
