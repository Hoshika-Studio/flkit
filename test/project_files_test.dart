import 'dart:io';

import 'package:hoshika_flkit/utils/project_files.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('project files', () {
    late Directory projectDirectory;

    setUp(() {
      projectDirectory = Directory.systemTemp.createTempSync(
        'flkit_project_files_',
      );
    });

    tearDown(() {
      if (projectDirectory.existsSync()) {
        projectDirectory.deleteSync(recursive: true);
      }
    });

    test('reads supported locales from flkit.yaml', () {
      File(p.join(projectDirectory.path, 'flkit.yaml')).writeAsStringSync('''
flkit:
  locales:
    supported:
      - fr
      - en
''');

      expect(readFlkitManifestLanguages(projectDirectory), ['en', 'fr']);
      expect(detectTranslationLanguages(projectDirectory), ['en', 'fr']);
    });

    test('ignores invalid flkit.yaml', () {
      File(
        p.join(projectDirectory.path, 'flkit.yaml'),
      ).writeAsStringSync('nope: [');

      expect(readFlkitManifestLanguages(projectDirectory), isEmpty);
    });
  });
}
