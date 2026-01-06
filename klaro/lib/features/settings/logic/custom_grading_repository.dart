import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:drift/drift.dart';

// Provider for all custom grading systems
final customGradingSystemsProvider = StreamProvider<List<CustomGradingSystem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.customGradingSystems).watch();
});

// Provider for scales of a specific system
final customGradingScalesProvider = StreamProvider.family<List<CustomGradingScale>, int>((ref, systemId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.customGradingScales)..where((s) => s.systemId.equals(systemId)))
      .watch();
});

// Provider for custom grading system actions
final customGradingActionsProvider = Provider<CustomGradingActions>((ref) => CustomGradingActions(ref));

class CustomGradingActions {
  final Ref ref;
  
  CustomGradingActions(this.ref);
  
  Future<int> createSystem({required String name, required bool isHigherBetter}) async {
    final db = ref.read(databaseProvider);
    return await db.into(db.customGradingSystems).insert(
      CustomGradingSystemsCompanion.insert(
        name: name,
        isHigherBetter: Value(isHigherBetter),
      ),
    );
  }
  
  Future<void> updateSystem(int id, String name) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.customGradingSystems)..where((s) => s.id.equals(id)))
        .write(CustomGradingSystemsCompanion(name: Value(name)));
  }
  
  Future<void> deleteSystem(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.customGradingSystems)..where((s) => s.id.equals(id))).go();
  }
  
  Future<void> addScale({
    required int systemId,
    required double minPercentage,
    required double gradeValue,
    String? gradeLabel,
  }) async {
    final db = ref.read(databaseProvider);
    await db.into(db.customGradingScales).insert(
      CustomGradingScalesCompanion.insert(
        systemId: systemId,
        minPercentage: minPercentage,
        gradeValue: gradeValue,
        gradeLabel: Value(gradeLabel),
      ),
    );
  }
  
  Future<void> updateScale({
    required int id,
    required double minPercentage,
    required double gradeValue,
    String? gradeLabel,
  }) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.customGradingScales)..where((s) => s.id.equals(id)))
        .write(CustomGradingScalesCompanion(
          minPercentage: Value(minPercentage),
          gradeValue: Value(gradeValue),
          gradeLabel: Value(gradeLabel),
        ));
  }
  
  Future<void> deleteScale(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.customGradingScales)..where((s) => s.id.equals(id))).go();
  }
  
  Future<CustomGradingSystem?> getSystem(int id) async {
    final db = ref.read(databaseProvider);
    return await (db.select(db.customGradingSystems)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }
  
  Future<List<CustomGradingScale>> getScalesForSystem(int systemId) async {
    final db = ref.read(databaseProvider);
    return await (db.select(db.customGradingScales)..where((s) => s.systemId.equals(systemId)))
        .get();
  }
}
