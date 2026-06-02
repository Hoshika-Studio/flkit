import 'package:args/command_runner.dart';
import 'package:hoshika_flkit/flkit_cli.dart';
import 'package:test/test.dart';

void main() {
  group('FlkitCommandRunner', () {
    test('prints the current version', () async {
      final output = <String>[];
      final runner = FlkitCommandRunner(printLine: output.add);

      await runner.run(['--version']);

      expect(output, ['flkit $flkitVersion']);
    });

    test('fails when create is missing the app name', () {
      final runner = FlkitCommandRunner();

      expect(
        () => runner.run(['create']),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains('Missing app name.'),
          ),
        ),
      );
    });

    test('accepts the starter template option', () {
      final runner = FlkitCommandRunner();

      final results = runner.parse([
        'create',
        'sample_app',
        '--template=starter',
        '--bundle-id=com.example.app',
        '--platforms=mobile',
      ]);

      expect(results.command?.name, 'create');
      expect(results.command?['template'], 'starter');
    });

    test('rejects unknown templates', () {
      final runner = FlkitCommandRunner();

      expect(
        () => runner.parse(['create', 'sample_app', '--template=blank']),
        throwsA(isA<UsageException>()),
      );
    });
  });
}
