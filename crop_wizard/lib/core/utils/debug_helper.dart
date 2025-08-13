import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

class DebugHelper {
  static final environmentLogger = createLogger(
    DebugHelper,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  static void logDataTypes(Map<String, dynamic> json) {
    environmentLogger.d('=== FMB Data Type Analysis ===');
    json.forEach((key, value) {
      environmentLogger.i('$key: ${value.runtimeType} = $value');
    });
    environmentLogger.d('===============================');
  }

  static void validateCoordinates(
      List<dynamic> coordinates, String surveyNumber) {
    try {
      environmentLogger.d('Survey $surveyNumber - Coordinate structure:');
      environmentLogger.d('Type: ${coordinates.runtimeType}');
      environmentLogger.d('Length: ${coordinates.length}');
      if (coordinates.isNotEmpty) {
        environmentLogger
            .d('First element type: ${coordinates[0].runtimeType}');
        if (coordinates[0] is List) {
          final firstLevel = coordinates[0] as List;
          environmentLogger.d('First level length: ${firstLevel.length}');
          if (firstLevel.isNotEmpty) {
            environmentLogger
                .d('Second level type: ${firstLevel[0].runtimeType}');
          }
        }
      }
    } catch (e) {
      environmentLogger
          .e('Error validating coordinates for survey $surveyNumber: $e');
    }
  }
}

// lib/core/utils/safe_parser.dart
class SafeParser {
  static final environmentLogger = createLogger(
    DebugHelper,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  static int? parseInt(dynamic value) {
    if (value == null) return null;

    try {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        if (value.isEmpty) return null;
        return int.tryParse(value);
      }
    } catch (e) {
      environmentLogger.e('Error parsing int from $value: $e');
    }

    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;

    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return null;
        return double.tryParse(value);
      }
    } catch (e) {
      environmentLogger.e('Error parsing double from $value: $e');
    }

    return null;
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;

    try {
      return value.toString();
    } catch (e) {
      environmentLogger.e('Error parsing string from $value: $e');
      return null;
    }
  }
}
