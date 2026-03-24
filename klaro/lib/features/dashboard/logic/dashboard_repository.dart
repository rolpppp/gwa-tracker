import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:drift/drift.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';

// Simple provider for courses list
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.select(db.courses).get();
});

// Provider for course actions
final courseActionsProvider = Provider<CourseActions>(
  (ref) => CourseActions(ref),
);

class CourseActions {
  final Ref ref;

  CourseActions(this.ref);

  Future<void> addCourse({
    required String name,
    required String code,
    required double targetGwa,
    required double units,
    required int termId,
  }) async {
    final db = ref.read(databaseProvider);

    await db
        .into(db.courses)
        .insert(
          CoursesCompanion.insert(
            name: name,
            code: code,
            units: units,
            targetGwa: targetGwa,
            colorHex: '#4ADE80', // Default Green
            termId: termId,
          ),
        );

    // Note: No need to invalidate since we're using a Stream that watches the database
  }
}

/// Calculates GWA for the given courses list.
/// [includeGoals] controls whether ghost/projected assessments are counted.
Future<double?> calculateGwaForCourses(
  AppDatabase db,
  List<Course> courses,
  String gradingSystem, {
  bool includeGoals = true,
}) async {
  if (courses.isEmpty) return null;

  double totalGradePoints = 0;
  double totalUnits = 0;

  for (var course in courses) {
    // Fetch components for this course
    final components = await (db.select(
      db.gradingComponents,
    )..where((c) => c.courseId.equals(course.id))).get();

    double courseWeightedScore = 0;
    double courseWeightUsed = 0;

    // Read this course's transmutation mode once per course.
    final transmutationMode = GradeCalculator.parseMode(course.transmutationMode);

    for (var comp in components) {
      // Fetch assessments for this component
      // Logic: If includeGoals is false, we strictly filter out assessments where isGoal is true
      final assessments =
          await (db.select(db.assessments)..where((a) {
                final baseFilter = a.componentId.equals(comp.id);
                if (!includeGoals) {
                  return baseFilter & a.isGoal.equals(false);
                }
                return baseFilter;
              }))
              .get();

      final score = GradeCalculator.calculateComponentScoreWithTransmutation(
        assessments,
        transmutationMode,
      );
      courseWeightedScore += (score * comp.weightPercent);
      courseWeightUsed += comp.weightPercent;
    }

    // If course has no data yet, skip it from calculation
    if (courseWeightUsed > 0) {
      double finalPct = courseWeightedScore / courseWeightUsed;
      double grade = await GradingSystem.convertAsync(
        finalPct,
        gradingSystem,
        db,
      );

      totalGradePoints += (grade * course.units);
      totalUnits += course.units;
    }
  }

  // If no courses have any grades yet, return null
  if (totalUnits == 0) {
    return null;
  } else {
    return totalGradePoints / totalUnits;
  }
}

// Projected GWA (Active Term Courses Only - Including Goals)
final overallGwaProvider = StreamProvider<double?>((ref) async* {
  final db = ref.watch(databaseProvider);
  final gradingSystem = ref.watch(activeGradingSystemProvider);
  final activeTermAsync = ref.watch(activeTermProvider);

  // Need an active term to show term-specific GWA
  if (activeTermAsync.value == null) {
    yield null;
    return;
  }
  final termId = activeTermAsync.value!.id;

  // Watch ALL assessments to trigger recalculation when any score changes
  // Optimization: Could filter by term if we joined tables, but watching all assessments is safer for now.
  final assessmentsStream = db.select(db.assessments).watch();

  await for (final _ in assessmentsStream) {
    // Fetch courses for the active term
    final courses = await (db.select(
      db.courses,
    )..where((c) => c.termId.equals(termId))).get();
    yield await calculateGwaForCourses(
      db,
      courses,
      gradingSystem,
      includeGoals: true,
    );
  }
});

// Real GWA (Active Term Courses Only - Excluding Goals)
final realGwaProvider = StreamProvider<double?>((ref) async* {
  final db = ref.watch(databaseProvider);
  final gradingSystem = ref.watch(activeGradingSystemProvider);
  final activeTermAsync = ref.watch(activeTermProvider);

  // Need an active term to show term-specific GWA
  if (activeTermAsync.value == null) {
    yield null;
    return;
  }
  final termId = activeTermAsync.value!.id;

  // Watch ALL assessments to trigger recalculation when any score changes
  final assessmentsStream = db.select(db.assessments).watch();

  await for (final _ in assessmentsStream) {
    // Fetch courses for the active term
    final courses = await (db.select(
      db.courses,
    )..where((c) => c.termId.equals(termId))).get();

    // Calculate GWA ignoring goal/projected assessments
    yield await calculateGwaForCourses(
      db,
      courses,
      gradingSystem,
      includeGoals: false,
    );
  }
});

// Semester Statistics Data Class
class SemesterStats {
  final int courseCount;
  final double totalUnits;
  final int coursesWithGrades;
  final int coursesWithoutGrades;

  const SemesterStats({
    required this.courseCount,
    required this.totalUnits,
    required this.coursesWithGrades,
    required this.coursesWithoutGrades,
  });

  bool get hasData => courseCount > 0;
}

// Semester Stats Provider (Active Term Only)
final semesterStatsProvider = StreamProvider<SemesterStats?>((ref) async* {
  final db = ref.watch(databaseProvider);
  final activeTermAsync = ref.watch(activeTermProvider);

  // Need an active term
  if (activeTermAsync.value == null) {
    yield null;
    return;
  }

  final termId = activeTermAsync.value!.id;

  // Watch courses to update stats when courses are added/removed
  final coursesStream = (db.select(
    db.courses,
  )..where((c) => c.termId.equals(termId))).watch();

  await for (final courses in coursesStream) {
    if (courses.isEmpty) {
      yield const SemesterStats(
        courseCount: 0,
        totalUnits: 0.0,
        coursesWithGrades: 0,
        coursesWithoutGrades: 0,
      );
      continue;
    }

    double totalUnits = 0.0;
    int coursesWithGrades = 0;
    int coursesWithoutGrades = 0;

    for (var course in courses) {
      totalUnits += course.units;

      // Check if course has any assessments (graded)
      final components = await (db.select(
        db.gradingComponents,
      )..where((c) => c.courseId.equals(course.id))).get();

      bool hasGrades = false;
      for (var component in components) {
        final assessments =
            await (db.select(db.assessments)..where(
                  (a) =>
                      a.componentId.equals(component.id) &
                      a.isGoal.equals(false),
                ))
                .get();

        if (assessments.isNotEmpty) {
          hasGrades = true;
          break;
        }
      }

      if (hasGrades) {
        coursesWithGrades++;
      } else {
        coursesWithoutGrades++;
      }
    }

    yield SemesterStats(
      courseCount: courses.length,
      totalUnits: totalUnits,
      coursesWithGrades: coursesWithGrades,
      coursesWithoutGrades: coursesWithoutGrades,
    );
  }
});
