import 'dart:convert';
import 'dart:io';

import 'package:hoshika_flkit/utils/string_case_extensions.dart';
import 'package:path/path.dart' as p;

class FeatureWriter {
  const FeatureWriter({
    required this.projectDirectory,
    required this.featureName,
    required this.packageName,
    required this.languages,
    required this.force,
  });

  final Directory projectDirectory;
  final String featureName;
  final String packageName;
  final List<String> languages;
  final bool force;

  String get className => featureName.toPascalCase();
  String get namespace => featureName.toCamelCase();

  void write() {
    final featureDirectory = Directory(
      p.join(projectDirectory.path, 'lib', 'features', featureName),
    );

    for (final directory in _featureDirectories) {
      Directory(
        p.join(featureDirectory.path, directory),
      ).createSync(recursive: true);
    }

    for (final directory in _emptyLayerDirectories) {
      _writeFile(
        File(p.join(featureDirectory.path, directory, '.gitkeep')),
        '',
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
      _screenContent,
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
        _translationContent(language),
      );
    }
  }

  static const _featureDirectories = [
    'application',
    'data',
    'domain',
    'i18n',
    'presentation',
  ];

  static const _emptyLayerDirectories = ['application', 'data', 'domain'];

  void _writeFile(File file, String content) {
    if (file.existsSync() && !force) return;

    file.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  String get _screenContent {
    return '''
import 'package:flutter/material.dart';
import 'package:$packageName/core/i18n/generated/strings.g.dart';
import 'package:$packageName/core/widgets/screen_shell.dart';

class ${className}Screen extends StatelessWidget {
  static const route = '${featureName.toRoutePath()}';

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

  String _translationContent(String language) {
    final displayName = featureName.toDisplayName();
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
}
