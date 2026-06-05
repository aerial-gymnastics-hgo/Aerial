import 'dart:io';

void main() {
  final file = File(r'lib/main.dart');
  if (!file.existsSync()) {
    print('Error: File does not exist');
    exit(1);
  }

  String content = file.readAsStringSync();

  // Normalize line endings
  content = content.replaceAll('\r\n', '\n');

  final target = """WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('--- CUSTOM FLUTTER ERROR ---');
    debugPrint('Exception: \${details.exception}');
    debugPrint('Stack trace:');
    debugPrintStack(stackTrace: details.stack);
    debugPrint('----------------------------');
  };

  WidgetsBinding.instance.platformDispatcher.onError = (Object error, StackTrace stack) {
    debugPrint('--- CUSTOM PLATFORM ERROR ---');
    debugPrint('Exception: \$error');
    debugPrint('Stack trace:');
    debugPrintStack(stackTrace: stack);
    debugPrint('-----------------------------');
    return true;
  };""";

  final replacement = "WidgetsFlutterBinding.ensureInitialized();";

  if (!content.contains(target)) {
    print('Error: Custom error handlers not found in main.dart');
    exit(1);
  }

  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content.replaceAll('\n', Platform.isWindows ? '\r\n' : '\n'));
  print('main.dart reverted successfully');
}
