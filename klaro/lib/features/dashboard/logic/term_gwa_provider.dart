import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';

/// GWA summary for a single term.
class TermGwaSummary {
  final Term term;
  final double? gwa;       // null = no real grades recorded yet
  final double totalUnits;
  final int courseCount;

  const TermGwaSummary({
    required this.term,
    required this.gwa,
    required this.totalUnits,
    required this.courseCount,
  });

  bool get hasData => gwa != null;
}

/// Computes real GWA (excluding goals) for every term, sorted newest → oldest.
/// Re-evaluates whenever any assessment is added, edited, or deleted.
final allTermsGwaProvider = StreamProvider<List<TermGwaSummary>>((ref) async* {
  final db = ref.watch(databaseProvider);
  final gradingSystem = ref.watch(activeGradingSystemProvider);

  final assessmentsStream = db.select(db.assessments).watch();

  await for (final _ in assessmentsStream) {
    final terms = await db.select(db.terms).get();
    final summaries = <TermGwaSummary>[];

    for (final term in terms) {
      final courses = await (db.select(db.courses)
            ..where((c) => c.termId.equals(term.id)))
          .get();

      final gwa = await calculateGwaForCourses(
        db,
        courses,
        gradingSystem,
        includeGoals: false,
      );
      final totalUnits = courses.fold(0.0, (sum, c) => sum + c.units);

      summaries.add(TermGwaSummary(
        term: term,
        gwa: gwa,
        totalUnits: totalUnits,
        courseCount: courses.length,
      ));
    }

    // Newest terms first (highest ID = most recently created).
    summaries.sort((a, b) => b.term.id.compareTo(a.term.id));
    yield summaries;
  }
});

/// All-time cumulative GWA: weighted average across every term that has real grades.
final cumulativeGwaProvider = Provider<double?>((ref) {
  return ref.watch(allTermsGwaProvider).when(
    data: (summaries) {
      double totalPoints = 0;
      double totalUnits = 0;

      for (final s in summaries) {
        if (s.hasData && s.totalUnits > 0) {
          totalPoints += s.gwa! * s.totalUnits;
          totalUnits += s.totalUnits;
        }
      }

      return totalUnits > 0 ? totalPoints / totalUnits : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
