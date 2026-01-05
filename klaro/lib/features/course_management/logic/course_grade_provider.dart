import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';

// Return type: Holds both real and projected grades
class CourseStanding {
  final double realPercentage;    // Based on actual records only
  final double realGrade;         // UP Grade (e.g., 1.75) based on real records
  
  final double projectedPercentage; // Real + Goal items
  final double projectedGrade;      // UP Grade including Goals
  
  final double weightGraded;      // Percentage of course weight that has assessments (0.0 to 1.0)

  CourseStanding({
    required this.realPercentage,
    required this.realGrade,
    required this.projectedPercentage,
    required this.projectedGrade,
    required this.weightGraded,
  });
  
  // Backwards compatibility getters
  double get percentage => realPercentage;
  double get finalGrade => realGrade;
  
  // Check if there's enough data to show a meaningful grade (at least 30% graded)
  bool get hasEnoughData => weightGraded >= 0.3;
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
    
    // Variables for REAL grade
    double realWeightedScore = 0.0;
    double realWeightUsed = 0.0;

    // Variables for PROJECTED grade (Real + Goals)
    double projWeightedScore = 0.0;
    double projWeightUsed = 0.0;

    // For every component (Quizzes, Exams...), calculate its score
    for (var component in components) {
      // Fetch assessments for this component
      final assessments = await (db.select(db.assessments)
        ..where((a) => a.componentId.equals(component.id))).get();
      
      // --- 1. Calculate REAL Score (exclude goals) ---
      final realAssessments = assessments.where((a) => !a.isGoal).toList();
      if (realAssessments.isNotEmpty) {
        final score = GradeCalculator.calculateComponentScore(realAssessments);
        realWeightedScore += (score * component.weightPercent);
        realWeightUsed += component.weightPercent;
      }

      // --- 2. Calculate PROJECTED Score (All items) ---
      if (assessments.isNotEmpty) {
        final score = GradeCalculator.calculateComponentScore(assessments);
        projWeightedScore += (score * component.weightPercent);
        projWeightUsed += component.weightPercent;
      }
    }

    // --- Normalize & Convert ---
    double finalRealPct = (realWeightUsed > 0) ? (realWeightedScore / realWeightUsed) : 0.0;
    double finalProjPct = (projWeightUsed > 0) ? (projWeightedScore / projWeightUsed) : 0.0;

    yield CourseStanding(
      realPercentage: finalRealPct,
      realGrade: GradingSystem.convertToUPGrade(finalRealPct),
      projectedPercentage: finalProjPct,
      projectedGrade: GradingSystem.convertToUPGrade(finalProjPct),
      weightGraded: realWeightUsed, // Track how much of the course has been graded
    );
  }
});