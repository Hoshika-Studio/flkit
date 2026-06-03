import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hoshika_flkit/create/starter_config.dart';
import 'package:hoshika_flkit/create/starter_language.dart';
import 'package:hoshika_flkit/create/starter_platform.dart';
import 'package:hoshika_flkit/create/starter_project_files.dart';
import 'package:hoshika_flkit/templates/template_locator.dart';
import 'package:hoshika_flkit/utils/cli_process_runner.dart';
import 'package:hoshika_flkit/utils/string_case_extensions.dart';
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
  CliProcessRunner get _processRunner => CliProcessRunner(_logger);

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

    final created = await _processRunner.run(
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
        'display_name': packageName.toDisplayName(),
        'use_riverpod': config.useRiverpod,
        'use_dio': config.useDio,
        'base_locale': StarterLanguage.en.code,
      },
    );

    removeUnselectedTranslations(
      projectDirectory: Directory(appName),
      selectedLanguages: languages,
    );
    writeFlkitManifest(
      projectDirectory: Directory(appName),
      packageName: packageName,
      useRiverpod: config.useRiverpod,
      useDio: config.useDio,
      languages: languages,
      baseLocale: StarterLanguage.en,
    );
    ensureEnvironmentFiles(Directory(appName));
    ensureEnvFilesAreIgnored(Directory(appName));

    final dependenciesInstalled = await _processRunner.run(
      message: 'Installing starter dependencies',
      executable: 'flutter',
      arguments: ['pub', 'get'],
      workingDirectory: appName,
      failureMessage: 'flutter pub get failed',
      successMessage: 'Starter dependencies installed',
    );

    if (!dependenciesInstalled) return;

    final translationsGenerated = await _processRunner.run(
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
      ..info('  dart run slang')
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

  String _toPackageName(String appName) {
    final packageName = p.basename(appName).toSnakeCase();

    return packageName.isEmpty ? 'sample_app' : packageName;
  }
}
