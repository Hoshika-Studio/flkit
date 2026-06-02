import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

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

  @override
  Future<void> run() async {
    final rawFeatureName = argResults?.rest.firstOrNull;

    if (rawFeatureName == null) {
      throw UsageException('Missing feature name.', usage);
    }

    final featureName = _toSnakeCase(rawFeatureName);
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

    final packageName = _readPackageName(pubspec);
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

    _createFeature(
      featureName: featureName,
      packageName: packageName,
      projectDirectory: projectDirectory,
      languages: languages,
      force: force,
    );

    _logger.success('Feature "$featureName" created');

    if (shouldRunSlang &&
        File(p.join(projectDirectory.path, 'slang.yaml')).existsSync()) {
      final generated = await _runStep(
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
      ..info('  Import ${_toPascalCase(featureName)}Screen where you need it')
      ..info('  Add a route or navigation entry if this feature needs one');
  }

  void _createFeature({
    required String featureName,
    required String packageName,
    required Directory projectDirectory,
    required List<String> languages,
    required bool force,
  }) {
    final namespace = _toCamelCase(featureName);
    final featureDirectory = Directory(
      p.join(projectDirectory.path, 'lib', 'features', featureName),
    );
    final directories = [
      'application',
      'data',
      'domain',
      'i18n',
      'presentation',
    ];

    for (final directory in directories) {
      Directory(
        p.join(featureDirectory.path, directory),
      ).createSync(recursive: true);
    }

    for (final directory in ['application', 'data', 'domain']) {
      _writeFile(
        File(p.join(featureDirectory.path, directory, '.gitkeep')),
        '',
        force: force,
      );
    }

    _writeFile(
      File(
        p.join(
          featureDirectory.path,
          'presentation',
          '${featureName}_screen.dart',
        ),
      ),
      _screenContent(featureName: featureName, packageName: packageName),
      force: force,
    );

    for (final language in languages) {
      _writeFile(
        File(
          p.join(
            featureDirectory.path,
            'i18n',
            '${namespace}_$language.i18n.json',
          ),
        ),
        _translationContent(featureName: featureName, language: language),
        force: force,
      );
    }
  }

  String _readPackageName(File pubspec) {
    final yaml = loadYaml(pubspec.readAsStringSync());

    if (yaml is! YamlMap || yaml['name'] is! String) {
      throw UsageException(
        'Could not read the package name from pubspec.yaml.',
        usage,
      );
    }

    return yaml['name'] as String;
  }

  List<String> _resolveLanguages(
    Directory projectDirectory,
    String? rawLanguages,
  ) {
    final languages = rawLanguages == null || rawLanguages.trim().isEmpty
        ? _detectLanguages(projectDirectory)
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

  List<String> _detectLanguages(Directory projectDirectory) {
    final libDirectory = Directory(p.join(projectDirectory.path, 'lib'));
    if (!libDirectory.existsSync()) return const [];

    final languages = <String>{};
    final localePattern = RegExp(r'_([a-z]{2})\.i18n\.json$');

    for (final file in libDirectory.listSync(recursive: true)) {
      if (file is! File) continue;

      final match = localePattern.firstMatch(p.basename(file.path));
      if (match != null) {
        languages.add(match.group(1)!);
      }
    }

    return languages.toList();
  }

  void _writeFile(File file, String content, {required bool force}) {
    if (file.existsSync() && !force) return;

    file.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  String _screenContent({
    required String featureName,
    required String packageName,
  }) {
    final className = _toPascalCase(featureName);
    final namespace = _toCamelCase(featureName);

    return '''
import 'package:flutter/material.dart';
import 'package:$packageName/core/i18n/generated/strings.g.dart';
import 'package:$packageName/core/widgets/screen_shell.dart';

class ${className}Screen extends StatelessWidget {
  static const route = '/${featureName.replaceAll('_', '-')}';

  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        title: t.$namespace.title,
        description: t.$namespace.description,
        child: Center(
          child: Text(t.$namespace.emptyState),
        ),
      ),
    );
  }
}
''';
  }

  String _translationContent({
    required String featureName,
    required String language,
  }) {
    final displayName = _toDisplayName(featureName);
    final translations = language == 'fr'
        ? {
            'title': displayName,
            'description': 'Gere $displayName depuis cet ecran.',
            'emptyState': 'Commence a construire cette feature.',
          }
        : {
            'title': displayName,
            'description': 'Manage $displayName from this screen.',
            'emptyState': 'Start building this feature.',
          };

    return '${const JsonEncoder.withIndent('  ').convert(translations)}\n';
  }

  String _toSnakeCase(String value) {
    return value
        .trim()
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _toPascalCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join();
  }

  String _toCamelCase(String value) {
    final pascal = _toPascalCase(value);
    if (pascal.isEmpty) return pascal;
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  String _toDisplayName(String value) {
    return value
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
    required String workingDirectory,
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
