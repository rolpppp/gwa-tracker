import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/core/logic/grading_system.dart';

void main() {
  testWidgets('Grading System Conversion Test', (WidgetTester tester) async {
    // Test the grading system conversions work correctly
    expect(GradingSystem.convertToUPGrade(98), 1.00);
    expect(GradingSystem.convertToUPGrade(93), 1.25);
    expect(GradingSystem.convertToUPGrade(60), 3.00);
    
    // Test 4-point system
    expect(GradingSystem.convertTo4PointGrade(97), 4.0);
    expect(GradingSystem.convertTo4PointGrade(93), 3.5);
    expect(GradingSystem.convertTo4PointGrade(89), 3.0);
    
    // Test US system
    expect(GradingSystem.convertToUSGrade(93), 4.0);
    expect(GradingSystem.convertToUSGrade(87), 3.3);
    
    // Build a simple widget to ensure test framework works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify basic widget rendering
    expect(find.text('Test'), findsOneWidget);
  });
}
