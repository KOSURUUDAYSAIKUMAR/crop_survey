import 'dart:convert';
import 'package:logger/logger.dart';
export 'package:logger/src/ansi_color.dart';

int _logSequence = 0;

final Map<Level, AnsiColor> customLevelColors = {
  Level.trace: const AnsiColor.fg(LoggerColors.grey),
  Level.debug: const AnsiColor.fg(LoggerColors.blue),
  Level.info: const AnsiColor.fg(LoggerColors.green),
  Level.warning: const AnsiColor.fg(LoggerColors.yellow),
  Level.error: const AnsiColor.fg(LoggerColors.red),
  Level.fatal: const AnsiColor.fg(LoggerColors.purple),
};

final Map<Level, String> customLevelEmojis = {
  Level.trace: '🔍',
  Level.debug: '🐛',
  Level.info: '💡',
  Level.warning: '⚠️',
  Level.error: '❌',
  Level.fatal: '🔥',
};

class CustomLogFilter extends LogFilter {
  // You can add properties here to control filtering logic, e.g.,
  // bool Function(String className)? classFilter;
  // List<String> allowedClassNames = [];
  // bool showStackTrace = true; // Example: a filter setting

  // For this example, let's keep it simple and just filter by minimum level
  // and potentially by class name if needed (though that requires more complex setup)

  // This should be true for production and false for development to see all logs
  final bool enableDebugLogs;

  CustomLogFilter({
    this.enableDebugLogs = true,
  }); // Default to showing debug logs

  @override
  bool shouldLog(LogEvent event) {
    if (event.level == Level.debug || event.level == Level.trace) {
      return enableDebugLogs; // Only log debug/trace if enableDebugLogs is true
    }
    // All other levels (info, warning, error, fatal) are always logged
    return true;
  }
}

Logger createLogger(
  Type type, {
  Level minLevel = Level.trace,
  bool enableDebugLogs = true,
}) {
  return Logger(
    printer: CustomLogPrinter(type.toString()),
    level: minLevel,
    filter: CustomLogFilter(enableDebugLogs: enableDebugLogs),
  );
}

class CustomLogPrinter extends LogPrinter {
  final String className;

  CustomLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    final color = customLevelColors[event.level] ??
        PrettyPrinter.defaultLevelColors[event.level];
    final emoji = customLevelEmojis[event.level] ??
        PrettyPrinter.defaultLevelEmojis[event.level];
    final time = DateTime.now().toIso8601String();
    final error = event.error;
    final stackTrace = event.stackTrace;
    final sequence = ++_logSequence;

    List<String> output = [];
    String messageString;
    Map<String, dynamic>? extraData;

    if (event.message is Map<String, dynamic>) {
      final Map<String, dynamic> msgMap = event.message as Map<String, dynamic>;
      messageString = msgMap['message']?.toString() ?? 'No message provided';
      extraData = Map.from(msgMap)..remove('message');
    } else {
      messageString = event.message.toString();
    }
    output.add(
      color!('$emoji : #$sequence : $time : $className : $messageString'),
    );
    if (extraData != null && extraData.isNotEmpty) {
      output.add(color('  Extra: ${jsonEncode(extraData)}'));
    }
    if (error != null) {
      output.add(color('  Error: $error'));
    }
    if (stackTrace != null) {
      output.add(
        color(
          '  Stack Trace:\n${stackTrace.toString().split('\n').map((line) => '    $line').join('\n')}',
        ),
      );
    }
    return output;
  }
}

class LoggerColors {
  static const int black = 30;
  static const int red = 31;
  static const int green = 32;
  static const int yellow = 33;
  static const int blue = 34;
  static const int magenta = 35;
  static const int cyan = 36;
  static const int white = 37;
  static const int grey = 90;
  static const int purple = 35;
}
