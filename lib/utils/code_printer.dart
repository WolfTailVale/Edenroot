import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  final libDir = Directory('A:\\edenroot\\lib');
  final output = File('ERCode.txt');
  final buffer = StringBuffer();

  const ignoredFilenames = {'ERCode.txt', 'code_printer.dart'};
  const ignoredDirectories = ['A:\\edenroot\\lib\\foundation', 'A:\\edenroot\\lib\\discord\\node_modules'];

  if (!await output.parent.exists()) {
    await output.parent.create(recursive: true);
  }

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && (entity.path.endsWith('.dart') || entity.path.endsWith('.js'))) {
      final filename = p.basename(entity.path);

      if (ignoredFilenames.contains(filename)) continue;
      if (ignoredDirectories.any((dir) => entity.path.startsWith(dir))) continue;

      final content = await entity.readAsString();
      buffer.writeln('// ================== ${entity.path} ==================\n');
      buffer.writeln(content);
      buffer.writeln('\n');
    }
  }

  await output.writeAsString(buffer.toString());
  print('✅ Full code dump written to ${output.path}');
}
