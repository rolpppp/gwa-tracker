import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';

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
    required double units
  }) async {
    final db = ref.read(databaseProvider);
    
    await db.into(db.courses).insert(
      CoursesCompanion.insert(
        name: name,
        code: code,
        units: units,
        targetGwa: targetGwa,
        colorHex: '#4ADE80', // Default Green
        termId: 1, // Hardcoded for MVP
      ),
    );
    
    // Refresh the courses list
    ref.invalidate(coursesProvider);
  }
}