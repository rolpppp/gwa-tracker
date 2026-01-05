import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:drift/drift.dart' hide Column;

// Provider for all terms
final termsProvider = StreamProvider<List<Term>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.terms).watch();
});

// Provider for the currently active term
final activeTermProvider = StreamProvider<Term?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.terms)..where((t) => t.isActive.equals(true))).watchSingleOrNull();
});

// Provider for courses in the active term
final coursesForActiveTermProvider = StreamProvider<List<Course>>((ref) async* {
  final db = ref.watch(databaseProvider);
  
  // Watch the active term directly
  await for (final activeTerm in (db.select(db.terms)..where((t) => t.isActive.equals(true))).watchSingleOrNull()) {
    if (activeTerm == null) {
      yield [];
      continue;
    }
    
    // Watch courses for this specific term
    await for (final courses in (db.select(db.courses)..where((c) => c.termId.equals(activeTerm.id))).watch()) {
      yield courses;
      break; // Break inner loop to re-check active term
    }
  }
});

// Provider for term actions
final termActionsProvider = Provider<TermActions>((ref) => TermActions(ref));

class TermActions {
  final Ref ref;
  
  TermActions(this.ref);
  
  /// Add a new term
  Future<int> addTerm(String name) async {
    final db = ref.read(databaseProvider);
    return await db.into(db.terms).insert(
      TermsCompanion.insert(
        name: name,
        isActive: const Value(false),
      ),
    );
  }
  
  /// Set a term as active (deactivates all others)
  Future<void> setActiveTerm(int termId) async {
    final db = ref.read(databaseProvider);
    
    // Deactivate all terms
    await (db.update(db.terms)..where((t) => t.isActive.equals(true)))
        .write(const TermsCompanion(isActive: Value(false)));
    
    // Activate selected term
    await (db.update(db.terms)..where((t) => t.id.equals(termId)))
        .write(const TermsCompanion(isActive: Value(true)));
  }
  
  /// Edit term name
  Future<void> updateTermName(int termId, String newName) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.terms)..where((t) => t.id.equals(termId)))
        .write(TermsCompanion(name: Value(newName)));
  }
  
  /// Delete a term (will cascade delete all courses and their data)
  Future<void> deleteTerm(int termId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.terms)..where((t) => t.id.equals(termId))).go();
  }
  
  /// Get courses for a specific term
  Stream<List<Course>> watchCoursesForTerm(int termId) {
    final db = ref.read(databaseProvider);
    return (db.select(db.courses)..where((c) => c.termId.equals(termId))).watch();
  }
}
