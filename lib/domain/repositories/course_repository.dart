import '../entities/course.dart';

abstract class CourseRepository {
  /// Fetches courses list. Prioritizes network fetch when online,
  /// falls back to local cache if offline or network fails.
  Future<List<Course>> getCourses({bool forceRefresh = false});

  /// Fetches a single course with its detailed lessons.
  Future<Course> getCourseById(int courseId);

  /// Toggles completion status of a lesson.
  /// If online: pushes immediately to remote API.
  /// If offline: updates local cache and enqueues to persistent offline mutation queue.
  Future<Course> toggleLessonCompletion({
    required int courseId,
    required int lessonId,
  });

  /// Synchronizes any pending offline mutations with the remote backend.
  Future<void> syncPendingMutations();

  /// Number of pending mutations queued offline.
  Future<int> get pendingMutationsCount;

  /// Current network connectivity status.
  Future<bool> get isConnected;

  /// Stream of network connectivity changes.
  Stream<bool> get onConnectivityChanged;

  /// Clears local cache for testing fresh state.
  Future<void> clearCache();
}
