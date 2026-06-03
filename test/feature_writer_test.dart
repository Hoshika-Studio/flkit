import 'dart:io';

import 'package:hoshika_flkit/add/feature_writer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FeatureWriter', () {
    late Directory projectDirectory;

    setUp(() {
      projectDirectory = Directory.systemTemp.createTempSync(
        'flkit_feature_writer_',
      );
    });

    tearDown(() {
      if (projectDirectory.existsSync()) {
        projectDirectory.deleteSync(recursive: true);
      }
    });

    test('writes feature-first folders, screen, and slang namespaces', () {
      FeatureWriter(
        projectDirectory: projectDirectory,
        featureName: 'user_profile',
        packageName: 'sample_app',
        languages: const ['en', 'fr'],
        force: false,
      ).write();

      final featurePath = p.join(
        projectDirectory.path,
        'lib',
        'features',
        'user_profile',
      );

      expect(Directory(p.join(featurePath, 'application')).existsSync(), true);
      expect(Directory(p.join(featurePath, 'data')).existsSync(), true);
      expect(Directory(p.join(featurePath, 'domain')).existsSync(), true);
      expect(Directory(p.join(featurePath, 'i18n')).existsSync(), true);
      expect(Directory(p.join(featurePath, 'presentation')).existsSync(), true);

      final screen = File(
        p.join(featurePath, 'presentation', 'user_profile_screen.dart'),
      ).readAsStringSync();

      expect(screen, contains('class UserProfileScreen'));
      expect(screen, contains("static const route = '/user-profile';"));
      expect(screen, contains('t.userProfile.title'));

      expect(
        File(
          p.join(featurePath, 'i18n', 'userProfile_en.i18n.json'),
        ).existsSync(),
        true,
      );
      expect(
        File(
          p.join(featurePath, 'i18n', 'userProfile_fr.i18n.json'),
        ).existsSync(),
        true,
      );
    });
  });
}
