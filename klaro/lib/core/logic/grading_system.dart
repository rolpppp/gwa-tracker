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

  /// Returns the color associated with the grade
  static int getGradeColor(double grade) {
    if (grade <= 1.25) return 0xFF4ADE80; // Mint Green (Excellent)
    if (grade <= 2.00) return 0xFF22D3EE; // Cyan (Good)
    if (grade <= 3.00) return 0xFFFACC15; // Yellow (Warning)
    return 0xFFEF4444; // Red (Fail)
  }
}