import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';

/// Result of a "what if I drop this course?" simulation.
class DropImpact {
  final String courseCode;
  final double courseUnits;
  final double? currentGwa;   // Real GWA with this course included
  final double? simulatedGwa; // Real GWA with this course removed
  final String gradingSystem;

  const DropImpact({
    required this.courseCode,
    required this.courseUnits,
    required this.currentGwa,
    required this.simulatedGwa,
    required this.gradingSystem,
  });

  bool get hasData => currentGwa != null;

  /// True when lower is better (5-Point). False for 4-Point / US.
  bool get isLowerBetter => gradingSystem == '5Point';

  /// Positive delta = GWA changed in a "better" direction after drop.
  double? get improvement {
    if (currentGwa == null || simulatedGwa == null) return null;
    return isLowerBetter
        ? currentGwa! - simulatedGwa! // 5-Point: improvement means simulated < current
        : simulatedGwa! - currentGwa!; // 4-Point/US: improvement means simulated > current
  }

  bool get dropHelps {
    final imp = improvement;
    return imp != null && imp > 0;
  }

  bool get dropHurts {
    final imp = improvement;
    return imp != null && imp < 0;
  }
}

/// Computes the GWA impact of dropping the course identified by [courseId].
/// Uses the same real-only (no goals) GWA logic as the main dashboard.
final dropSimulatorProvider =
    FutureProvider.family<DropImpact, int>((ref, courseId) async {
  final db = ref.read(databaseProvider);
  final gradingSystem = ref.read(activeGradingSystemProvider);

  final course = await (db.select(db.courses)
        ..where((c) => c.id.equals(courseId)))
      .getSingleOrNull();

  if (course == null) {
    return const DropImpact(
      courseCode: '?',
      courseUnits: 0,
      currentGwa: null,
      simulatedGwa: null,
      gradingSystem: '5Point',
    );
  }

  final allCourses = await (db.select(db.courses)
        ..where((c) => c.termId.equals(course.termId)))
      .get();

  final coursesWithout =
      allCourses.where((c) => c.id != courseId).toList();

  final currentGwa = await calculateGwaForCourses(
    db, allCourses, gradingSystem,
    includeGoals: false,
  );
  final simulatedGwa = coursesWithout.isEmpty
      ? null
      : await calculateGwaForCourses(
          db, coursesWithout, gradingSystem,
          includeGoals: false,
        );

  return DropImpact(
    courseCode: course.code,
    courseUnits: course.units,
    currentGwa: currentGwa,
    simulatedGwa: simulatedGwa,
    gradingSystem: gradingSystem,
  );
});
