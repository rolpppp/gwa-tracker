import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import the tables we just made
import 'package:klaro/features/course_management/data/database_tables.dart';

// Required for generation
part 'database.g.dart';

@DriftDatabase(tables: [Terms, Courses, GradingComponents, Assessments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add isGoal column to assessments table
          await m.addColumn(assessments, assessments.isGoal as GeneratedColumn);
        }
      },
    );
  }

  // 1. Fetch all Components for a specific Course
  Future<List<GradingComponent>> getComponentsForCourse(int courseId) {
    return (select(gradingComponents)..where((tbl) => tbl.courseId.equals(courseId))).get();
  }

  // 2. Fetch all Assessments for a specific Component
  Future<List<Assessment>> getAssessmentsForComponent(int componentId) {
    return (select(assessments)..where((tbl) => tbl.componentId.equals(componentId))).get();
  }

  // 3. (Stream) Watch everything for a Course (Reactive UI)
  // This is a "Power Query" that joins tables. 
  // For the MVP, we will stick to simple independent streams to keep it readable.
  Stream<List<GradingComponent>> watchComponents(int courseId) {
    return (select(gradingComponents)..where((tbl) => tbl.courseId.equals(courseId))).watch();
  }
  
  Stream<List<Assessment>> watchAssessments(int componentId) {
    return (select(assessments)..where((tbl) => tbl.componentId.equals(componentId))).watch();
  }
}


// Lazy Database Connection Logic
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 1. Get the folder where app can store data
    final dbFolder = await getApplicationDocumentsDirectory();
    
    // 2. Create the file "db.sqlite"
    final file = File(p.join(dbFolder.path, 'gradepal.sqlite'));
    
    // 3. Open the Native SQLite connection
    return NativeDatabase.createInBackground(file);
  });
}

// --- RIVERPOD PROVIDER ---
// This allows any part of the app to access the database just by 
// asking for `ref.watch(databaseProvider)`
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return AppDatabase();
}