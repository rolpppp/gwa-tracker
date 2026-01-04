import 'package:drift/drift.dart';

// Table 1: Terms (Semesters)
class Terms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "1st Sem 2024-2025"
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
}

// Table 2: Courses (Subjects)
class Courses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text()(); // "CMSC 11"
  TextColumn get name => text()(); // "Intro to CS"
  RealColumn get units => real()(); // 3.0
  RealColumn get targetGwa => real()(); // 1.75
  TextColumn get colorHex => text()(); // "#FF5500" - for UI

  // Foreign Key: Links to a Term
  IntColumn get termId => integer().references(Terms, #id)();
}

// Table 3: Grading Components (Buckets)
// e.g., "Quizzes" (15%), "Exams" (40%)
class GradingComponents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "Quizzes"
  RealColumn get weightPercent => real()(); // 0.15 for 15%
  
  // Foreign Key: Links to a Course
  IntColumn get courseId => integer().references(Courses, #id, onDelete: KeyAction.cascade)();
}

// Table 4: Assessments (Actual Scores)
class Assessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "Quiz 1"
  RealColumn get scoreObtained => real()(); // 15.0
  RealColumn get totalItems => real()(); // 20.0
  BoolColumn get isExcused => boolean().withDefault(const Constant(false))();
  
  // Foreign Key: Links to a Component
  IntColumn get componentId => integer().references(GradingComponents, #id, onDelete: KeyAction.cascade)();
}