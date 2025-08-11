// lib/core/utils/debug_helper.dart
class DebugHelper {
  static void logDataTypes(Map<String, dynamic> json) {
    print('=== FMB Data Type Analysis ===');
    json.forEach((key, value) {
      print('$key: ${value.runtimeType} = $value');
    });
    print('===============================');
  }

  static void validateCoordinates(
      List<dynamic> coordinates, String surveyNumber) {
    try {
      print('Survey $surveyNumber - Coordinate structure:');
      print('Type: ${coordinates.runtimeType}');
      print('Length: ${coordinates.length}');
      if (coordinates.isNotEmpty) {
        print('First element type: ${coordinates[0].runtimeType}');
        if (coordinates[0] is List) {
          final firstLevel = coordinates[0] as List;
          print('First level length: ${firstLevel.length}');
          if (firstLevel.isNotEmpty) {
            print('Second level type: ${firstLevel[0].runtimeType}');
          }
        }
      }
    } catch (e) {
      print('Error validating coordinates for survey $surveyNumber: $e');
    }
  }
}

// lib/core/utils/safe_parser.dart
class SafeParser {
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
      print('Error parsing int from $value: $e');
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
      print('Error parsing double from $value: $e');
    }

    return null;
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;

    try {
      return value.toString();
    } catch (e) {
      print('Error parsing string from $value: $e');
      return null;
    }
  }
}
