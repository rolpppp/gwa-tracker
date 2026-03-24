import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';

// Return type: Holds both real and projected grades
class CourseStanding {
  final double realPercentage;      // Raw % from actual records (before grade conversion)
  final double realGrade;           // Converted grade (e.g., 1.75 UP) from real records

  final double projectedPercentage; // Raw % including goal/ghost assessments
  final double projectedGrade;      // Converted grade including goals

  final double weightGraded;        // Fraction of course weight that has real assessments (0.0–1.0)

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

  // At least 30% of the course weight must be graded to show a meaningful grade
  bool get hasEnoughData => weightGraded >= 0.3;
}

// StreamProvider.family for a single course's standing.
// Re-emits whenever any assessment changes, fetching the course's
// transmutation mode fresh each time so changes take effect immediately.
final courseStandingProvider = StreamProvider.family<CourseStanding, int>((ref, courseId) async* {
  final db = ref.watch(databaseProvider);

  // Trigger recalculation whenever any assessment is added/edited/deleted.
  final allAssessmentsStream = db.select(db.assessments).watch();

  await for (final _ in allAssessmentsStream) {
    // Fetch the course to read its current transmutation mode.
    final course = await (db.select(db.courses)
      ..where((c) => c.id.equals(courseId))).getSingleOrNull();

    final transmutationMode = GradeCalculator.parseMode(
      course?.transmutationMode ?? 'none',
    );

    final components = await (db.select(db.gradingComponents)
      ..where((c) => c.courseId.equals(courseId))).get();

    // Accumulators for real (no goals) and projected (with goals) grades.
    double realWeightedScore = 0.0;
    double realWeightUsed   = 0.0;
    double projWeightedScore = 0.0;
    double projWeightUsed   = 0.0;

    for (var component in components) {
      final assessments = await (db.select(db.assessments)
        ..where((a) => a.componentId.equals(component.id))).get();

      // --- Real score: excludes goal/ghost assessments ---
      final realAssessments = assessments.where((a) => !a.isGoal).toList();
      if (realAssessments.isNotEmpty) {
        final score = GradeCalculator.calculateComponentScoreWithTransmutation(
          realAssessments,
          transmutationMode,
        );
        realWeightedScore += score * component.weightPercent;
        realWeightUsed    += component.weightPercent;
      }

      // --- Projected score: all assessments (real + goals) ---
      if (assessments.isNotEmpty) {
        final score = GradeCalculator.calculateComponentScoreWithTransmutation(
          assessments,
          transmutationMode,
        );
        projWeightedScore += score * component.weightPercent;
        projWeightUsed    += component.weightPercent;
      }
    }

    // Normalize by the weight actually used (handles partially-set-up courses).
    final finalRealPct = (realWeightUsed > 0) ? (realWeightedScore / realWeightUsed) : 0.0;
    final finalProjPct = (projWeightUsed > 0) ? (projWeightedScore / projWeightUsed) : 0.0;

    yield CourseStanding(
      realPercentage:      finalRealPct,
      realGrade:           GradingSystem.convertToUPGrade(finalRealPct),
      projectedPercentage: finalProjPct,
      projectedGrade:      GradingSystem.convertToUPGrade(finalProjPct),
      weightGraded:        realWeightUsed,
    );
  }
});
