import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/core/utils/progress_calculator.dart';

void main() {
  group('ProgressCalculator', () {
    test('calculates correct percentage for standard course milestones', () {
      // Test cases from the assignment specification
      // Python Programming: 13 / 20 = 65%
      expect(
        ProgressCalculator.calculate(completedLessons: 13, totalLessons: 20),
        equals(65),
      );

      // Full Stack Development: 7 / 28 = 25%
      expect(
        ProgressCalculator.calculate(completedLessons: 7, totalLessons: 28),
        equals(25),
      );

      // Halfway completed: 5 / 10 = 50%
      expect(
        ProgressCalculator.calculate(completedLessons: 5, totalLessons: 10),
        equals(50),
      );
    });

    test('rounds floating point percentages correctly to nearest integer', () {
      // 1 / 3 = 33.333% -> rounds to 33
      expect(
        ProgressCalculator.calculate(completedLessons: 1, totalLessons: 3),
        equals(33),
      );

      // 2 / 3 = 66.666% -> rounds to 67
      expect(
        ProgressCalculator.calculate(completedLessons: 2, totalLessons: 3),
        equals(67),
      );
    });

    test('safely handles edge cases without throwing division by zero', () {
      // Total lessons is 0
      expect(
        ProgressCalculator.calculate(completedLessons: 0, totalLessons: 0),
        equals(0),
      );

      // Negative lessons safety
      expect(
        ProgressCalculator.calculate(completedLessons: -1, totalLessons: 10),
        equals(0),
      );

      // 0 completed lessons
      expect(
        ProgressCalculator.calculate(completedLessons: 0, totalLessons: 15),
        equals(0),
      );

      // Completed lessons equal to total lessons
      expect(
        ProgressCalculator.calculate(completedLessons: 20, totalLessons: 20),
        equals(100),
      );

      // Completed lessons exceeding total lessons (clamped to 100)
      expect(
        ProgressCalculator.calculate(completedLessons: 25, totalLessons: 20),
        equals(100),
      );
    });

    test('calculates accurate fraction for UI progress indicators (0.0 to 1.0)', () {
      expect(
        ProgressCalculator.calculateFraction(completedLessons: 13, totalLessons: 20),
        closeTo(0.65, 0.001),
      );

      expect(
        ProgressCalculator.calculateFraction(completedLessons: 0, totalLessons: 10),
        equals(0.0),
      );

      expect(
        ProgressCalculator.calculateFraction(completedLessons: 10, totalLessons: 10),
        equals(1.0),
      );
    });
  });
}
