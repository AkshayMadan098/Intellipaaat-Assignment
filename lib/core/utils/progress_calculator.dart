/// Utility class for calculating course progress
class ProgressCalculator {
  const ProgressCalculator._();

  /// Calculates the progress percentage (0 - 100) based on completed lessons and total lessons.
  static int calculate({
    required int completedLessons,
    required int totalLessons,
  }) {
    if (totalLessons <= 0) return 0;
    if (completedLessons <= 0) return 0;
    if (completedLessons >= totalLessons) return 100;

    final double percentage = (completedLessons / totalLessons) * 100.0;
    return percentage.round().clamp(0, 100);
  }

  /// Calculates progress as a float between 0.0 and 1.0 for UI progress bars.
  static double calculateFraction({
    required int completedLessons,
    required int totalLessons,
  }) {
    if (totalLessons <= 0 || completedLessons <= 0) return 0.0;
    if (completedLessons >= totalLessons) return 1.0;
    return (completedLessons / totalLessons).clamp(0.0, 1.0);
  }
}
