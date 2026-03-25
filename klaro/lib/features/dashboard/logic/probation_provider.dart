import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/logic/grade_display_helper.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';

class ProbationRisk {
  final int failingCount;
  final int atRiskCount;
  final List<String> failingCourseNames;
  final List<String> atRiskCourseNames;

  const ProbationRisk({
    required this.failingCount,
    required this.atRiskCount,
    required this.failingCourseNames,
    required this.atRiskCourseNames,
  });

  /// True when failing 2 or more courses — typical Philippine probation trigger.
  bool get isProbationRisk => failingCount >= 2;

  /// True when at least one course is failing or at risk.
  bool get hasWarnings => failingCount > 0 || atRiskCount > 0;

  int get totalAtRisk => failingCount + atRiskCount;
}

/// Watches all assessments and recomputes academic risk counts for the active term.
/// Yields null when there is no active term or no concerning courses.
final probationRiskProvider = StreamProvider<ProbationRisk?>((ref) async* {
  final db = ref.watch(databaseProvider);
  final gradingSystem = ref.watch(activeGradingSystemProvider);
  final activeTermAsync = ref.watch(activeTermProvider);

  if (activeTermAsync.value == null) {
    yield null;
    return;
  }

  final termId = activeTermAsync.value!.id;
  final assessmentsStream = db.select(db.assessments).watch();

  await for (final _ in assessmentsStream) {
    final courses = await (db.select(db.courses)
          ..where((c) => c.termId.equals(termId)))
        .get();

    if (courses.isEmpty) {
      yield null;
      continue;
    }

    int failingCount = 0;
    int atRiskCount = 0;
    final failingNames = <String>[];
    final atRiskNames = <String>[];

    for (final course in courses) {
      final transmutationMode =
          GradeCalculator.parseMode(course.transmutationMode);
      final components = await (db.select(db.gradingComponents)
            ..where((c) => c.courseId.equals(course.id)))
          .get();

      double weightedScore = 0.0;
      double weightUsed = 0.0;

      for (final comp in components) {
        final realAssessments = await (db.select(db.assessments)
              ..where((a) =>
                  a.componentId.equals(comp.id) & a.isGoal.equals(false)))
            .get();

        if (realAssessments.isNotEmpty) {
          final score =
              GradeCalculator.calculateComponentScoreWithTransmutation(
            realAssessments,
            transmutationMode,
          );
          weightedScore += score * comp.weightPercent;
          weightUsed += comp.weightPercent;
        }
      }

      // Require at least 30% of the course weight graded before flagging
      if (weightUsed < 30.0) continue;

      final percentage = weightedScore / weightUsed;
      final status =
          GradeDisplayHelper.getCourseStatus(percentage, gradingSystem);

      if (status == CourseStatus.failing) {
        failingCount++;
        failingNames.add(course.code);
      } else if (status == CourseStatus.atRisk) {
        atRiskCount++;
        atRiskNames.add(course.code);
      }
    }

    if (failingCount == 0 && atRiskCount == 0) {
      yield null;
    } else {
      yield ProbationRisk(
        failingCount: failingCount,
        atRiskCount: atRiskCount,
        failingCourseNames: failingNames,
        atRiskCourseNames: atRiskNames,
      );
    }
  }
});
