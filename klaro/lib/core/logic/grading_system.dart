class GradingSystem {
  /// Converts a raw percentage (0-100) to the UP Grading System (1.0 - 5.0)
  static double convertToUPGrade(double percentage) {
    if (percentage >= 96) return 1.00;
    if (percentage >= 92) return 1.25;
    if (percentage >= 88) return 1.50;
    if (percentage >= 84) return 1.75;
    if (percentage >= 80) return 2.00;
    if (percentage >= 75) return 2.25;
    if (percentage >= 70) return 2.50;
    if (percentage >= 65) return 2.75;
    if (percentage >= 60) return 3.00;
    // 4.0 usually implies conditional/removal, but for calc we skip to 5.0
    return 5.00;
  }

  /// Converts a raw percentage (0-100) to 4-Point GPA (4.0 - 0.0)
  /// Based on the system: 4.0=Excellent, 3.5=Superior, 3.0=Very Good, etc.
  static double convertTo4PointGrade(double percentage) {
    if (percentage >= 97) return 4.0;  // Excellent
    if (percentage >= 93) return 3.5;  // Superior
    if (percentage >= 89) return 3.0;  // Very Good
    if (percentage >= 85) return 2.5;  // Good
    if (percentage >= 80) return 2.0;  // Satisfactory
    if (percentage >= 75) return 1.5;  // Fair
    if (percentage >= 70) return 1.0;  // Pass
    return 0.0;                        // Fail
  }

  /// Converts a raw percentage (0-100) to US Letter Grade GPA (4.0 - 0.0)
  static double convertToUSGrade(double percentage) {
    if (percentage >= 93) return 4.0;  // A
    if (percentage >= 90) return 3.7;  // A-
    if (percentage >= 87) return 3.3;  // B+
    if (percentage >= 83) return 3.0;  // B
    if (percentage >= 80) return 2.7;  // B-
    if (percentage >= 77) return 2.3;  // C+
    if (percentage >= 73) return 2.0;  // C
    if (percentage >= 70) return 1.7;  // C-
    if (percentage >= 67) return 1.3;  // D+
    if (percentage >= 65) return 1.0;  // D
    return 0.0;                        // F
  }

  /// Generic conversion based on system string
  static double convert(double percentage, String system) {
    switch (system) {
      case 'UP': return convertToUPGrade(percentage);
      case '4Point': return convertTo4PointGrade(percentage);
      case 'US': return convertToUSGrade(percentage);
      default: return convertToUPGrade(percentage);
    }
  }

  /// Returns the color associated with the grade (works for all systems)
  static int getGradeColor(double grade) {
    if (grade <= 1.25) return 0xFF4ADE80; // Mint Green (Excellent)
    if (grade <= 2.00) return 0xFF22D3EE; // Cyan (Good)
    if (grade <= 3.00) return 0xFFFACC15; // Yellow (Warning)
    return 0xFFEF4444; // Red (Fail)
  }

  /// Get color for 4-point system (higher is better)
  static int get4PointGradeColor(double grade) {
    if (grade >= 3.5) return 0xFF4ADE80; // Mint Green (Excellent)
    if (grade >= 2.5) return 0xFF22D3EE; // Cyan (Good)
    if (grade >= 1.5) return 0xFFFACC15; // Yellow (Warning)
    return 0xFFEF4444; // Red (Fail)
  }

  /// Returns the color based on the selected system
  static int getColor(double grade, String system) {
    if (system == 'UP') {
      return getGradeColor(grade);
    } else {
      return get4PointGradeColor(grade);
    }
  }

  /// Converts a GPA (0.0 - 4.0) to US Letter Grade
  /// This is an approximation based on standard GPA scales
  static String getUSLetter(double gpa) {
    if (gpa >= 4.0) return 'A';
    if (gpa >= 3.7) return 'A-';
    if (gpa >= 3.3) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.7) return 'B-';
    if (gpa >= 2.3) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.7) return 'C-';
    if (gpa >= 1.3) return 'D+';
    if (gpa >= 1.0) return 'D';
    return 'F';
  }
}