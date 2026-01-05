import 'package:klaro/core/logic/grading_system.dart';

class GradeDisplayHelper {
  /// Converts a percentage (0-100) to a grade string based on the selected grading system
  static String formatGrade(double percentage, String gradingSystem) {
    switch (gradingSystem) {
      case 'UP':
        return GradingSystem.convertToUPGrade(percentage).toStringAsFixed(2);
      case '4Point':
        return GradingSystem.convertTo4PointGrade(percentage).toStringAsFixed(2);
      case 'US':
        return GradingSystem.convertToUSGrade(percentage).toStringAsFixed(2);
      default:
        return GradingSystem.convertToUPGrade(percentage).toStringAsFixed(2);
    }
  }
  
  /// Gets the system label (e.g., "GWA", "GPA", "GPA")
  static String getSystemLabel(String gradingSystem) {
    switch (gradingSystem) {
      case 'UP':
        return 'GWA';
      case '4Point':
      case 'US':
        return 'GPA';
      default:
        return 'GWA';
    }
  }
  
  /// Gets the grade scale description
  static String getScaleDescription(String gradingSystem) {
    switch (gradingSystem) {
      case 'UP':
        return '1.0 - 5.0';
      case '4Point':
      case 'US':
        return '0.0 - 4.0';
      default:
        return '1.0 - 5.0';
    }
  }
  
  /// Checks if lower is better (UP system) or higher is better (US/4-Point)
  static bool isLowerBetter(String gradingSystem) {
    return gradingSystem == 'UP';
  }
  
  /// Returns grade color based on the percentage and system
  static int getGradeColorForSystem(double percentage, String gradingSystem) {
    final grade = _getNumericGrade(percentage, gradingSystem);
    
    if (gradingSystem == 'UP') {
      // Lower is better for UP
      return GradingSystem.getGradeColor(grade);
    } else {
      // Higher is better for 4-Point and US
      return GradingSystem.get4PointGradeColor(grade);
    }
  }
  
  static double _getNumericGrade(double percentage, String gradingSystem) {
    switch (gradingSystem) {
      case 'UP':
        return GradingSystem.convertToUPGrade(percentage);
      case '4Point':
        return GradingSystem.convertTo4PointGrade(percentage);
      case 'US':
        return GradingSystem.convertToUSGrade(percentage);
      default:
        return GradingSystem.convertToUPGrade(percentage);
    }
  }
}
