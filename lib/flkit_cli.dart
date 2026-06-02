import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:hoshika_flkit/commands/add_command.dart';
import 'package:hoshika_flkit/commands/create_command.dart';

const flkitVersion = '0.2.0';

class FlkitCommandRunner extends CommandRunner<void> {
  FlkitCommandRunner({void Function(String message)? printLine})
    : _printLine = printLine ?? print,
      super('flkit', 'A Flutter starter generator.') {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the FLKit version.',
    );

    addCommand(AddCommand());
    addCommand(CreateCommand());
  }

  final void Function(String message) _printLine;

  @override
  void printUsage() => _printLine(usage);

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      _printLine('flkit $flkitVersion');
      return;
    }

    await super.runCommand(topLevelResults);
  }
}
