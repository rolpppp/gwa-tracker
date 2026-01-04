import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';

// Return type: A simple object holding both % and Grade
class CourseStanding {
  final double percentage; // e.g., 92.5
  final double finalGrade; // e.g., 1.25

  CourseStanding(this.percentage, this.finalGrade);
}

// Manual StreamProvider.family for course standing
final courseStandingProvider = StreamProvider.family<CourseStanding, int>((ref, courseId) async* {
  final db = ref.watch(databaseProvider);

  // Listen to ALL assessments for this course (to detect any assessment changes)
  final allAssessmentsStream = db.select(db.assessments).watch();
  
  await for (final _ in allAssessmentsStream) {
    // Recalculate whenever ANY assessment changes
    final components = await (db.select(db.gradingComponents)
      ..where((c) => c.courseId.equals(courseId))).get();
    
    double totalWeightedScore = 0.0;
    double totalWeightUsed = 0.0;

    // For every component (Quizzes, Exams...), calculate its score
    for (var component in components) {
      // Fetch assessments for this component
      final assessments = await (db.select(db.assessments)
        ..where((a) => a.componentId.equals(component.id))).get();
      
      final componentScore = GradeCalculator.calculateComponentScore(assessments);
      
      // Accumulate Weighted Score
      totalWeightedScore += (componentScore * component.weightPercent);
      totalWeightUsed += component.weightPercent;
    }

    // Normalize
    double finalPercentage = 0.0;
    if (totalWeightUsed > 0) {
      finalPercentage = totalWeightedScore / totalWeightUsed;
    }

    // Convert to UP Grade
    final upGrade = GradingSystem.convertToUPGrade(finalPercentage);

    yield CourseStanding(finalPercentage, upGrade);
  }
});