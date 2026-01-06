import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/core/logic/grade_display_helper.dart';

void main() {
  testWidgets('Grading System Conversion Test', (WidgetTester tester) async {
    // Test 5Point (UP) system conversions
    expect(GradingSystem.convertToUPGrade(98), 1.00);
    expect(GradingSystem.convertToUPGrade(93), 1.25);
    expect(GradingSystem.convertToUPGrade(60), 3.00);
    expect(GradingSystem.convertToUPGrade(55), 5.00);
    
    // Test 4-point system
    expect(GradingSystem.convertTo4PointGrade(97), 4.0);
    expect(GradingSystem.convertTo4PointGrade(93), 3.5);
    expect(GradingSystem.convertTo4PointGrade(89), 3.0);
    expect(GradingSystem.convertTo4PointGrade(65), 0.0);
    
    // Test US system
    expect(GradingSystem.convertToUSGrade(93), 4.0);
    expect(GradingSystem.convertToUSGrade(87), 3.3);
    expect(GradingSystem.convertToUSGrade(73), 2.0);
    expect(GradingSystem.convertToUSGrade(60), 0.0);
    
    // Test generic convert method
    expect(GradingSystem.convert(98, '5Point'), 1.00);
    expect(GradingSystem.convert(97, '4Point'), 4.0);
    expect(GradingSystem.convert(93, 'US'), 4.0);
    
    // Build a simple widget to ensure test framework works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Klaro Test'),
          ),
        ),
      ),
    );

    // Verify basic widget rendering
    expect(find.text('Klaro Test'), findsOneWidget);
  });
  
  testWidgets('Grade Display Helper Test', (WidgetTester tester) async {
    // Test grade formatting
    expect(GradeDisplayHelper.formatGrade(98, '5Point'), '1.00');
    expect(GradeDisplayHelper.formatGrade(97, '4Point'), '4.00');
    expect(GradeDisplayHelper.formatGrade(93, 'US'), '4.00'); // Returns numeric GPA
    
    // Test system labels
    expect(GradeDisplayHelper.getSystemLabel('5Point'), 'GWA');
    expect(GradeDisplayHelper.getSystemLabel('4Point'), 'GPA');
    expect(GradeDisplayHelper.getSystemLabel('US'), 'GPA');
    
    // Test isLowerBetter logic
    expect(GradeDisplayHelper.isLowerBetter('5Point'), true);
    expect(GradeDisplayHelper.isLowerBetter('4Point'), false);
    expect(GradeDisplayHelper.isLowerBetter('US'), false);
  });
}
