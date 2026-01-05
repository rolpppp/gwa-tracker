import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';

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

// Overall GWA calculator provider (returns null if no data)
final overallGwaProvider = StreamProvider<double?>((ref) async* {
  final db = ref.watch(databaseProvider);
  
  // Watch ALL assessments to trigger recalculation when any score changes
  final assessmentsStream = db.select(db.assessments).watch();

  await for (final _ in assessmentsStream) {
    // Fetch all courses
    final courses = await db.select(db.courses).get();
    
    // If there are no courses at all, return null
    if (courses.isEmpty) {
      yield null;
      continue;
    }
    
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
        final assessments = await (db.select(db.assessments)
          ..where((a) => a.componentId.equals(comp.id))).get();
        final score = GradeCalculator.calculateComponentScore(assessments);
        courseWeightedScore += (score * comp.weightPercent);
        courseWeightUsed += comp.weightPercent;
      }
      
      // If course has no data yet, skip it from calculation
      if (courseWeightUsed > 0) {
        double finalPct = courseWeightedScore / courseWeightUsed;
        double grade = GradingSystem.convertToUPGrade(finalPct);
        
        totalGradePoints += (grade * course.units);
        totalUnits += course.units;
      }
    }

    // If no courses have any grades yet, return null
    if (totalUnits == 0) {
      yield null;
    } else {
      yield totalGradePoints / totalUnits;
    }
  }
});