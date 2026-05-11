import 'package:args/command_runner.dart';
import 'package:flkit/commands/create_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<void>('flkit', 'A Flutter starter generator.')
    ..addCommand(CreateCommand());

  await runner.run(args);
}
