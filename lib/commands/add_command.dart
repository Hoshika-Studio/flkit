import 'package:args/command_runner.dart';
import 'package:hoshika_flkit/commands/add_feature_command.dart';

class AddCommand extends Command<void> {
  AddCommand() {
    addSubcommand(AddFeatureCommand());
  }

  @override
  String get name => 'add';

  @override
  String get description => 'Add code to an existing Flutter project.';
}
