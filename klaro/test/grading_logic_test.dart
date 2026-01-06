import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';
import 'package:klaro/core/services/database.dart';

void main() {
  group('5Point Grading System (UP)', () {
    test('High scores should return 1.0 - 1.25', () {
      expect(GradingSystem.convertToUPGrade(98), 1.00); // 96-100
      expect(GradingSystem.convertToUPGrade(93), 1.25); // 92-95.9
      expect(GradingSystem.convertToUPGrade(96), 1.00); // Boundary
    });

    test('Passing cutoff should be exact', () {
      expect(GradingSystem.convertToUPGrade(60), 3.00); // Pass
      expect(GradingSystem.convertToUPGrade(59.9), 5.00); // Fail
    });

    test('Middle range accuracy', () {
      expect(GradingSystem.convertToUPGrade(85), 1.75);
      expect(GradingSystem.convertToUPGrade(80), 2.00);
      expect(GradingSystem.convertToUPGrade(75), 2.25);
      expect(GradingSystem.convertToUPGrade(70), 2.50);
    });
    
    test('All grade boundaries', () {
      expect(GradingSystem.convertToUPGrade(96), 1.00);
      expect(GradingSystem.convertToUPGrade(92), 1.25);
      expect(GradingSystem.convertToUPGrade(88), 1.50);
      expect(GradingSystem.convertToUPGrade(84), 1.75);
      expect(GradingSystem.convertToUPGrade(80), 2.00);
      expect(GradingSystem.convertToUPGrade(75), 2.25);
      expect(GradingSystem.convertToUPGrade(70), 2.50);
      expect(GradingSystem.convertToUPGrade(65), 2.75);
      expect(GradingSystem.convertToUPGrade(60), 3.00);
      expect(GradingSystem.convertToUPGrade(55), 5.00);
    });
  });
  
  group('4Point Grading System', () {
    test('High scores should return 4.0', () {
      expect(GradingSystem.convertTo4PointGrade(97), 4.0);
      expect(GradingSystem.convertTo4PointGrade(100), 4.0);
    });
    
    test('All grade boundaries', () {
      expect(GradingSystem.convertTo4PointGrade(97), 4.0);  // Excellent
      expect(GradingSystem.convertTo4PointGrade(93), 3.5);  // Superior
      expect(GradingSystem.convertTo4PointGrade(89), 3.0);  // Very Good
      expect(GradingSystem.convertTo4PointGrade(85), 2.5);  // Good
      expect(GradingSystem.convertTo4PointGrade(80), 2.0);  // Satisfactory
      expect(GradingSystem.convertTo4PointGrade(75), 1.5);  // Fair
      expect(GradingSystem.convertTo4PointGrade(70), 1.0);  // Pass
      expect(GradingSystem.convertTo4PointGrade(65), 0.0);  // Fail
    });
  });
  
  group('US Grading System', () {
    test('Letter grade equivalents', () {
      expect(GradingSystem.convertToUSGrade(93), 4.0);  // A
      expect(GradingSystem.convertToUSGrade(90), 3.7);  // A-
      expect(GradingSystem.convertToUSGrade(87), 3.3);  // B+
      expect(GradingSystem.convertToUSGrade(83), 3.0);  // B
      expect(GradingSystem.convertToUSGrade(80), 2.7);  // B-
      expect(GradingSystem.convertToUSGrade(77), 2.3);  // C+
      expect(GradingSystem.convertToUSGrade(73), 2.0);  // C
      expect(GradingSystem.convertToUSGrade(70), 1.7);  // C-
      expect(GradingSystem.convertToUSGrade(67), 1.3);  // D+
      expect(GradingSystem.convertToUSGrade(65), 1.0);  // D
      expect(GradingSystem.convertToUSGrade(60), 0.0);  // F
    });
    
    test('US Letter grade conversion', () {
      expect(GradingSystem.getUSLetter(4.0), 'A');
      expect(GradingSystem.getUSLetter(3.7), 'A-');
      expect(GradingSystem.getUSLetter(3.3), 'B+');
      expect(GradingSystem.getUSLetter(3.0), 'B');
      expect(GradingSystem.getUSLetter(2.7), 'B-');
      expect(GradingSystem.getUSLetter(2.3), 'C+');
      expect(GradingSystem.getUSLetter(2.0), 'C');
      expect(GradingSystem.getUSLetter(1.0), 'D');
      expect(GradingSystem.getUSLetter(0.0), 'F');
    });
  });
  
  group('Generic Conversion', () {
    test('Convert method routes to correct system', () {
      expect(GradingSystem.convert(98, '5Point'), 1.00);
      expect(GradingSystem.convert(97, '4Point'), 4.0);
      expect(GradingSystem.convert(93, 'US'), 4.0);
    });
  });
  
  group('Custom Grading System', () {
    test('Custom system conversion with scales', () {
      final scales = [
        CustomGradingScale(
          id: 1,
          systemId: 1,
          minPercentage: 96.0,
          gradeValue: 1.0,
        ),
        CustomGradingScale(
          id: 2,
          systemId: 1,
          minPercentage: 90.0,
          gradeValue: 1.25,
        ),
        CustomGradingScale(
          id: 3,
          systemId: 1,
          minPercentage: 85.0,
          gradeValue: 1.5,
        ),
        CustomGradingScale(
          id: 4,
          systemId: 1,
          minPercentage: 80.0,
          gradeValue: 2.0,
        ),
        CustomGradingScale(
          id: 5,
          systemId: 1,
          minPercentage: 75.0,
          gradeValue: 2.5,
        ),
      ];
      
      expect(GradingSystem.convertWithCustomSystem(98, scales), 1.0);
      expect(GradingSystem.convertWithCustomSystem(92, scales), 1.25);
      expect(GradingSystem.convertWithCustomSystem(87, scales), 1.5);
      expect(GradingSystem.convertWithCustomSystem(82, scales), 2.0);
      expect(GradingSystem.convertWithCustomSystem(77, scales), 2.5);
      expect(GradingSystem.convertWithCustomSystem(70, scales), 2.5); // Below all thresholds
    });
  });
  
  group('Grade Color Logic', () {
    test('5Point system colors (lower is better)', () {
      expect(GradingSystem.getGradeColor(1.00), 0xFF4ADE80); // Excellent
      expect(GradingSystem.getGradeColor(1.25), 0xFF4ADE80); // Excellent
      expect(GradingSystem.getGradeColor(1.75), 0xFF22D3EE); // Good
      expect(GradingSystem.getGradeColor(2.50), 0xFFFACC15); // Warning
      expect(GradingSystem.getGradeColor(5.00), 0xFFEF4444); // Fail
    });
    
    test('4Point system colors (higher is better)', () {
      expect(GradingSystem.get4PointGradeColor(4.0), 0xFF4ADE80); // Excellent
      expect(GradingSystem.get4PointGradeColor(3.5), 0xFF4ADE80); // Excellent
      expect(GradingSystem.get4PointGradeColor(3.0), 0xFF22D3EE); // Good
      expect(GradingSystem.get4PointGradeColor(2.0), 0xFFFACC15); // Warning
      expect(GradingSystem.get4PointGradeColor(0.5), 0xFFEF4444); // Fail
    });
  });
  
  group('Component Score Calculation', () {
    test('Calculate component score from assessments', () {
      final assessments = <Assessment>[
        Assessment(
          id: 1,
          componentId: 1,
          name: 'Quiz 1',
          scoreObtained: 45,
          totalItems: 50,
          isExcused: false,
          isGoal: false,
        ),
        Assessment(
          id: 2,
          componentId: 1,
          name: 'Quiz 2',
          scoreObtained: 38,
          totalItems: 50,
          isExcused: false,
          isGoal: false,
        ),
      ];
      
      final score = GradeCalculator.calculateComponentScore(assessments);
      // (45 + 38) / (50 + 50) * 100 = 83 / 100 * 100 = 83%
      expect(score, 83.0);
    });
    
    test('Empty assessments should return 0', () {
      expect(GradeCalculator.calculateComponentScore([]), 0.0);
    });
    
    test('Excused assessments should be ignored', () {
      final assessments = <Assessment>[
        Assessment(
          id: 1,
          componentId: 1,
          name: 'Quiz 1',
          scoreObtained: 45,
          totalItems: 50,
          isExcused: false,
          isGoal: false,
        ),
        Assessment(
          id: 2,
          componentId: 1,
          name: 'Quiz 2',
          scoreObtained: 0,
          totalItems: 50,
          isExcused: true,
          isGoal: false,
        ),
      ];
      
      final score = GradeCalculator.calculateComponentScore(assessments);
      // Only Quiz 1 counts: 45/50 * 100 = 90%
      expect(score, 90.0);
    });
  });
  
  group('Overall Grade Calculation', () {
    test('Calculate weighted overall grade', () {
      final components = [
        GradingComponent(
          id: 1,
          courseId: 1,
          name: 'Quizzes',
          weightPercent: 30,
        ),
        GradingComponent(
          id: 2,
          courseId: 1,
          name: 'Exams',
          weightPercent: 70,
        ),
      ];
      
      final componentScores = {
        1: 85.0, // Quizzes: 85%
        2: 90.0, // Exams: 90%
      };
      
      final overall = GradeCalculator.calculateOverallGrade(components, componentScores);
      // weightPercent is stored as actual percentage: 85 * 30 + 90 * 70 = 8850
      expect(overall, 8850.0);
    });
    
    test('Empty components should return 0', () {
      expect(GradeCalculator.calculateOverallGrade([], {}), 0.0);
    });
  });
}