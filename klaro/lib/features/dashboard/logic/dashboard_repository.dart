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
final courseActionsProvider = Provider<CourseActions>((ref) => CourseActions(ref));

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
    
    await db.into(db.courses).insert(
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

// Helper function to calculate GWA for a list of courses
Future<double?> _calculateGwaImpl(AppDatabase db, List<Course> courses, String gradingSystem, {bool includeGoals = true}) async {
  if (courses.isEmpty) return null;
  
  double totalGradePoints = 0;
  double totalUnits = 0;

  for (var course in courses) {
    // Fetch components for this course
    final components = await (db.select(db.gradingComponents)
      ..where((c) => c.courseId.equals(course.id))).get();
    
    double courseWeightedScore = 0;
    double courseWeightUsed = 0;
    
    for(var comp in components) {
      // Fetch assessments for this component
      // Logic: If includeGoals is false, we strictly filter out assessments where isGoal is true
      final assessments = await (db.select(db.assessments)
        ..where((a) {
          final baseFilter = a.componentId.equals(comp.id);
          if (!includeGoals) {
            return baseFilter & a.isGoal.equals(false);
          }
          return baseFilter;
        })).get();

      final score = GradeCalculator.calculateComponentScore(assessments);
      courseWeightedScore += (score * comp.weightPercent);
      courseWeightUsed += comp.weightPercent;
    }
    
    // If course has no data yet, skip it from calculation
    if (courseWeightUsed > 0) {
      double finalPct = courseWeightedScore / courseWeightUsed;
      double grade = await GradingSystem.convertAsync(finalPct, gradingSystem, db);
      
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
    final courses = await (db.select(db.courses)..where((c) => c.termId.equals(termId))).get();
    yield await _calculateGwaImpl(db, courses, gradingSystem, includeGoals: true);
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
    final courses = await (db.select(db.courses)..where((c) => c.termId.equals(termId))).get();
    
    // Calculate GWA ignoring goal/projected assessments
    yield await _calculateGwaImpl(db, courses, gradingSystem, includeGoals: false);
  }
});