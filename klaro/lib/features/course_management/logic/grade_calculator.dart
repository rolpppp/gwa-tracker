import 'package:klaro/core/services/database.dart'; // To get the classes

/// Transmutation mode applied to a course's raw component scores.
///
/// Philippine universities commonly use transmutation to ensure that even a
/// zero raw score does not result in a zero grade. The formula is linear:
///   Transmuted = (rawPct / 100) * range + floor
///
/// - none   (Base 0):  No transmutation. Grade = raw percentage.
/// - base50 (Base 50): floor=50, range=50. Raw 0%->50, Raw 100%->100.
/// - base60 (Base 60): floor=40, range=60. Raw 0%->40, Raw 100%->100.
///   Used by DepEd K-12; some private colleges adopt this variant.
enum TransmutationMode { none, base50, base60 }

class GradeCalculator {

  /// Parses a stored transmutation string into the enum.
  static TransmutationMode parseMode(String mode) {
    switch (mode) {
      case 'base50': return TransmutationMode.base50;
      case 'base60': return TransmutationMode.base60;
      default:       return TransmutationMode.none;
    }
  }

  /// Applies transmutation to a raw percentage (0–100).
  ///
  /// Transmutation is a linear transformation that raises the floor grade so
  /// that a student who scores zero does not receive a zero percentage.
  /// It does NOT change the maximum (100% stays 100%).
  ///
  /// Base 50:  Transmuted = (raw / 100) × 50 + 50
  /// Base 60:  Transmuted = (raw / 100) × 60 + 40
  /// None:     Transmuted = raw (identity, no change)
  static double applyTransmutation(double rawPercentage, TransmutationMode mode) {
    switch (mode) {
      case TransmutationMode.base50:
        return (rawPercentage / 100.0) * 50.0 + 50.0;
      case TransmutationMode.base60:
        return (rawPercentage / 100.0) * 60.0 + 40.0;
      case TransmutationMode.none:
        return rawPercentage;
    }
  }

  /// Calculates the % score for a single bucket (e.g., "Quizzes").
  ///
  /// Logic: pools all non-excused scores together.
  ///   Score = (Sum of Earned) / (Sum of Total Items) × 100
  ///
  /// This is the raw percentage BEFORE any transmutation.
  static double calculateComponentScore(List<Assessment> assessments) {
    if (assessments.isEmpty) return 0.0;

    double totalScore = 0;
    double maxScore = 0;

    for (var assessment in assessments) {
      if (!assessment.isExcused) {
        totalScore += assessment.scoreObtained;
        maxScore += assessment.totalItems;
      }
    }

    if (maxScore == 0) return 0.0;
    return (totalScore / maxScore) * 100;
  }

  /// Calculates the component score and applies transmutation.
  ///
  /// Transmutation is applied to the pooled raw percentage of the component
  /// (not per individual assessment), which is mathematically equivalent to
  /// per-assessment transmutation when assessments share the same total items,
  /// and is consistent with how most Philippine professors report component grades.
  static double calculateComponentScoreWithTransmutation(
    List<Assessment> assessments,
    TransmutationMode mode,
  ) {
    final rawScore = calculateComponentScore(assessments);
    return applyTransmutation(rawScore, mode);
  }

  /// Calculates the final weighted grade for the course.
  ///
  /// Logic: Sum(Component Score × Weight)
  /// weightPercent is stored as a fraction (0.30 for 30%).
  static double calculateOverallGrade(
    List<GradingComponent> components,
    Map<int, double> componentScores,
  ) {
    double finalGrade = 0.0;

    for (var component in components) {
      final score = componentScores[component.id] ?? 0.0;
      finalGrade += score * component.weightPercent;
    }

    return finalGrade;
  }
}
