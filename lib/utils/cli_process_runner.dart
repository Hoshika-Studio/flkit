import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

class CliProcessRunner {
  const CliProcessRunner(this._logger);

  final Logger _logger;

  Future<bool> run({
    required String message,
    required String executable,
    required List<String> arguments,
    required String failureMessage,
    required String successMessage,
    String? workingDirectory,
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
