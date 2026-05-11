import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';

class CreateCommand extends Command<void> {
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

    final org = _logger.prompt(
      'Organization ID',
      defaultValue: 'com.example.app',
    );

    final useRiverpod = _logger.confirm(
      'Use Riverpod Generator?',
      defaultValue: true,
    );

    final progress = _logger.progress('Creating Flutter project');

    final result = await Process.run('flutter', [
      'create',
      appName,
      '--org',
      org,
    ], runInShell: true);

    if (result.exitCode != 0) {
      progress.fail('Flutter create failed');
      _logger.err(result.stderr.toString());
      return;
    }

    progress.complete('Flutter project created');

    final brick = Brick.path('bricks/starter');
    final generator = await MasonGenerator.fromBrick(brick);

    await generator.generate(
      DirectoryGeneratorTarget(Directory(appName)),
      vars: {'app_name': appName, 'use_riverpod': useRiverpod},
    );

    _logger.success('Done 🚀');
  }
}
