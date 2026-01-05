import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/core/logic/grading_system.dart';

void main() {
  group('UP Grading System Logic', () {
    test('High scores should return 1.0 - 1.25', () {
      expect(GradingSystem.convertToUPGrade(98), 1.00); // 96-100
      expect(GradingSystem.convertToUPGrade(93), 1.25); // 92-95.9
    });

    test('Passing cutoff should be exact', () {
      expect(GradingSystem.convertToUPGrade(60), 3.00); // Pass
      expect(GradingSystem.convertToUPGrade(59.9), 5.00); // Fail
    });

    test('Middle range accuracy', () {
      expect(GradingSystem.convertToUPGrade(85), 1.75);
    });
  });
}