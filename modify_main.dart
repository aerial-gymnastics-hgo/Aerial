import 'dart:io';

void main() {
  final file = File(r'lib/main.dart');
  if (!file.existsSync()) {
    print('Error: File does not exist');
    exit(1);
  }

  String content = file.readAsStringSync();

  final target = "WidgetsFlutterBinding.ensureInitialized();";
  final replacement = """WidgetsFlutterBinding.ensureInitialized();

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

  if (!content.contains(target)) {
    print('Error: Target not found in main.dart');
    exit(1);
  }

  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('main.dart modified successfully');
}
