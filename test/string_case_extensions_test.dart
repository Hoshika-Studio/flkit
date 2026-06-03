import 'package:hoshika_flkit/utils/string_case_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StringCaseExtensions', () {
    test('converts user input to snake case', () {
      expect('UserProfile'.toSnakeCase(), 'user_profile');
      expect('user profile'.toSnakeCase(), 'user_profile');
      expect('user-profile'.toSnakeCase(), 'user_profile');
    });

    test('converts snake case to Dart names and labels', () {
      expect('user_profile'.toPascalCase(), 'UserProfile');
      expect('user_profile'.toCamelCase(), 'userProfile');
      expect('user_profile'.toDisplayName(), 'User Profile');
      expect('user_profile'.toRoutePath(), '/user-profile');
    });
  });
}
