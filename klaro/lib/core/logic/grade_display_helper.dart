import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/core/services/database.dart';

class GradeDisplayHelper {
  /// Converts a percentage (0-100) to a grade string based on the selected grading system
  static String formatGrade(double percentage, String gradingSystem) {
    switch (gradingSystem) {
      case '5Point':
        return GradingSystem.convertToUPGrade(percentage).toStringAsFixed(2);
      case '4Point':
        return GradingSystem.convertTo4PointGrade(percentage).toStringAsFixed(2);
      case 'US':
        return GradingSystem.convertToUSGrade(percentage).toStringAsFixed(2);
      default:
        if (gradingSystem.startsWith('custom_')) {
          return percentage.toStringAsFixed(2); // Will be converted later
        }
        return GradingSystem.convertToUPGrade(percentage).toStringAsFixed(2);
    }
  }
  
  /// Async version for custom systems
  static Future<String> formatGradeAsync(double percentage, String gradingSystem, AppDatabase db) async {
    if (gradingSystem.startsWith('custom_')) {
      final grade = await GradingSystem.convertAsync(percentage, gradingSystem, db);
      return grade.toStringAsFixed(2);
    }
    return formatGrade(percentage, gradingSystem);
  }
  
  /// Gets the system label (e.g., "GWA", "GPA", "GPA")
  static String getSystemLabel(String gradingSystem) {
    switch (gradingSystem) {
      case '5Point':
        return 'GWA';
      case '4Point':
      case 'US':
        return 'GPA';
      default:
        if (gradingSystem.startsWith('custom_')) {
          return 'Grade'; // Generic label for custom systems
        }
        return 'GWA';
    }
  }
  
  /// Async version that can fetch custom system details
  static Future<String> getSystemLabelAsync(String gradingSystem, AppDatabase db) async {
    if (gradingSystem.startsWith('custom_')) {
      final systemIdStr = gradingSystem.substring(7);
      final systemId = int.tryParse(systemIdStr);
      if (systemId != null) {
        final customSystem = await (db.select(db.customGradingSystems)
          ..where((s) => s.id.equals(systemId)))
          .getSingleOrNull();
        if (customSystem != null) {
          return customSystem.isHigherBetter ? 'GPA' : 'GWA';
        }
      }
    }
    return getSystemLabel(gradingSystem);
  }
  
  /// Gets the grade scale description
  static String getScaleDescription(String gradingSystem) {
    switch (gradingSystem) {
      case '5Point':
        return '1.0 - 5.0';
      case '4Point':
      case 'US':
        return '0.0 - 4.0';
      default:
        if (gradingSystem.startsWith('custom_')) {
          return 'Custom Scale';
        }
        return '1.0 - 5.0';
    }
  }
  
  /// Checks if lower is better (5Point system) or higher is better (US/4-Point)
  static bool isLowerBetter(String gradingSystem) {
    if (gradingSystem.startsWith('custom_')) {
      // Default to lower is better for custom systems (will need async version for accuracy)
      return true;
    }
    return gradingSystem == '5Point';
  }
  
  /// Async version for custom systems
  static Future<bool> isLowerBetterAsync(String gradingSystem, AppDatabase db) async {
    if (gradingSystem.startsWith('custom_')) {
      final systemIdStr = gradingSystem.substring(7);
      final systemId = int.tryParse(systemIdStr);
      if (systemId != null) {
        final customSystem = await (db.select(db.customGradingSystems)
          ..where((s) => s.id.equals(systemId)))
          .getSingleOrNull();
        if (customSystem != null) {
          return !customSystem.isHigherBetter; // Invert because isLowerBetter is opposite
        }
      }
    }
    return isLowerBetter(gradingSystem);
  }
  
  /// Returns grade color based on the percentage and system
  static int getGradeColorForSystem(double percentage, String gradingSystem) {
    final grade = _getNumericGrade(percentage, gradingSystem);
    
    if (gradingSystem == '5Point' || gradingSystem.startsWith('custom_')) {
      // Lower is better for 5Point and assume custom
      return GradingSystem.getGradeColor(grade);
    } else {
      // Higher is better for 4-Point and US
      return GradingSystem.get4PointGradeColor(grade);
    }
  }
  
  static double _getNumericGrade(double percentage, String gradingSystem) {
    switch (gradingSystem) {
      case '5Point':
        return GradingSystem.convertToUPGrade(percentage);
      case '4Point':
        return GradingSystem.convertTo4PointGrade(percentage);
      case 'US':
        return GradingSystem.convertToUSGrade(percentage);
      default:
        if (gradingSystem.startsWith('custom_')) {
          return percentage; // Placeholder, needs async conversion
        }
        return GradingSystem.convertToUPGrade(percentage);
    }
  }
}
