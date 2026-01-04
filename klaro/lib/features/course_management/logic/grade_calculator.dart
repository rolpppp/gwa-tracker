import 'package:klaro/core/services/database.dart'; // To get the classes

class GradeCalculator {
  
  /// Calculates the % score for a single bucket (e.g., "Quizzes")
  /// Logic: (Sum of Scores / Sum of Total Items) * 100
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

  /// Calculates the final weighted grade for the Course
  /// Logic: Sum (Component Score * Weight)
  static double calculateOverallGrade(
    List<GradingComponent> components, 
    Map<int, double> componentScores // Map<ComponentID, Score>
  ) {
    double finalGrade = 0.0;
    
    for (var component in components) {
      final score = componentScores[component.id] ?? 0.0;
      // weightPercent is stored as 0.15 for 15%
      finalGrade += score * component.weightPercent; 
    }

    return finalGrade; // Returns e.g., 88.5
  }
}