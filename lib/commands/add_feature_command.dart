import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hoshika_flkit/add/feature_writer.dart';
import 'package:hoshika_flkit/utils/cli_process_runner.dart';
import 'package:hoshika_flkit/utils/project_files.dart';
import 'package:hoshika_flkit/utils/string_case_extensions.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

class AddFeatureCommand extends Command<void> {
  AddFeatureCommand() {
    argParser
      ..addOption(
        'project-dir',
        help: 'Flutter project directory. Defaults to the current directory.',
      )
      ..addOption(
        'languages',
        help: 'Comma-separated locale codes. Defaults to detected i18n files.',
      )
      ..addFlag(
        'run-slang',
        defaultsTo: true,
        help: 'Run "dart run slang" after creating i18n files.',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite the feature files if they already exist.',
      );
  }

  @override
  String get name => 'feature';

  @override
  String get description => 'Add a feature-first feature folder.';

  final Logger _logger = Logger();
  CliProcessRunner get _processRunner => CliProcessRunner(_logger);

  @override
  Future<void> run() async {
    final rawFeatureName = argResults?.rest.firstOrNull;

    if (rawFeatureName == null) {
      throw UsageException('Missing feature name.', usage);
    }

    final featureName = rawFeatureName.toSnakeCase();
    if (featureName.isEmpty) {
      throw UsageException('Invalid feature name "$rawFeatureName".', usage);
    }

    final projectDirectory = Directory(
      argResults?['project-dir'] as String? ?? Directory.current.path,
    );
    final force = argResults?['force'] as bool? ?? false;
    final shouldRunSlang = argResults?['run-slang'] as bool? ?? true;

    final pubspec = File(p.join(projectDirectory.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw UsageException(
        'Could not find pubspec.yaml. Run this command from a Flutter project root.',
        usage,
      );
    }

    final packageName = readPackageName(pubspec);
    if (packageName == null) {
      throw UsageException(
        'Could not read the package name from pubspec.yaml.',
        usage,
      );
    }

    final featureDirectory = Directory(
      p.join(projectDirectory.path, 'lib', 'features', featureName),
    );

    if (featureDirectory.existsSync() && !force) {
      throw UsageException(
        'Feature "$featureName" already exists. Use --force to overwrite it.',
        usage,
      );
    }

    final languages = _resolveLanguages(
      projectDirectory,
      argResults?['languages'] as String?,
    );

    FeatureWriter(
      featureName: featureName,
      packageName: packageName,
      projectDirectory: projectDirectory,
      languages: languages,
      force: force,
    ).write();

    _logger.success('Feature "$featureName" created');

    if (shouldRunSlang &&
        File(p.join(projectDirectory.path, 'slang.yaml')).existsSync()) {
      final generated = await _processRunner.run(
        message: 'Generating translations',
        executable: 'dart',
        arguments: ['run', 'slang'],
        workingDirectory: projectDirectory.path,
        failureMessage: 'Slang generation failed',
        successMessage: 'Translations generated',
      );

      if (!generated) return;
    }

    _logger
      ..info('')
      ..info('Next steps:')
      ..info('  Import ${featureName.toPascalCase()}Screen where you need it')
      ..info('  Add a route or navigation entry if this feature needs one');
  }

  List<String> _resolveLanguages(
    Directory projectDirectory,
    String? rawLanguages,
  ) {
    final languages = rawLanguages == null || rawLanguages.trim().isEmpty
        ? detectTranslationLanguages(projectDirectory)
        : rawLanguages
              .split(',')
              .map((language) => language.trim().toLowerCase())
              .where((language) => language.isNotEmpty)
              .toSet()
              .toList();

    if (languages.isEmpty) return ['en', 'fr'];

    languages.sort();
    return languages;
  }
}
