import 'dart:isolate';

import 'package:path/path.dart' as p;

Future<String> resolveTemplatePath(String name) async {
  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:hoshika_flkit/flkit.dart'),
  );

  if (packageUri == null) {
    throw StateError('Unable to resolve the FLKit package location.');
  }

  final packageRoot = p.dirname(p.dirname(packageUri.toFilePath()));
  return p.join(packageRoot, 'bricks', name);
}
