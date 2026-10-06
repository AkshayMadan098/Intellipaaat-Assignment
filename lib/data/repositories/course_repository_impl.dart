import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/progress_calculator.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course_model.dart';
import '../models/lesson_progress_mutation.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;
  final CourseLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  CourseRepositoryImpl({
    required CourseRemoteDataSource remoteDataSource,
    required CourseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<bool> get isConnected => _networkInfo.isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _networkInfo.onConnectivityChanged;

  @override
  Future<int> get pendingMutationsCount async {
    final mutations = await _localDataSource.getPendingMutations();
    return mutations.length;
  }

  @override
  Future<void> syncPendingMutations() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) return;

    final mutations = await _localDataSource.getPendingMutations();
    if (mutations.isEmpty) return;

    for (final mutation in mutations) {
      try {
        await _remoteDataSource.syncLessonProgress(
          courseId: mutation.courseId,
          lessonId: mutation.lessonId,
          isCompleted: mutation.isCompleted,
        );
        await _localDataSource.removeMutation(mutation.id);
      } catch (_) {
        // If an individual sync fails, stop and retain remaining queue for next retry
        break;
      }
    }
  }

  @override
  Future<List<Course>> getCourses({bool forceRefresh = false}) async {
    final isOnline = await _networkInfo.isConnected;

    // If device is offline, serve cached data directly
    if (!isOnline) {
      final hasCache = await _localDataSource.hasCachedData();
      if (hasCache) {
        final cached = await _localDataSource.getCachedCourses();
        return cached.map((c) => c.toEntity()).toList();
      }
      throw const NetworkFailure(
        'No internet connection and no cached courses available on this device.',
      );
    }

    // Synchronize any pending offline mutations first
    await syncPendingMutations();

    // When online, perform network-first fetch with fallback to cache
    try {
      final remoteList = await _remoteDataSource.fetchCourses();

      // Retrieve cached courses to preserve locally completed lessons
      List<CourseModel> cachedList = [];
      try {
        cachedList = await _localDataSource.getCachedCourses();
      } catch (_) {
        cachedList = [];
      }

      final Map<int, CourseModel> cachedMap = {
        for (final c in cachedList) c.id: c,
      };

      // Merge: retain user's lesson progress from local cache if available
      final mergedList = remoteList.map((remoteCourse) {
        final cached = cachedMap[remoteCourse.id];
        if (cached != null && cached.lessons.isNotEmpty) {
          return cached;
        }
        return remoteCourse;
      }).toList();

      await _localDataSource.cacheCourses(mergedList);
      return mergedList.map((c) => c.toEntity()).toList();
    } on Failure catch (_) {
      // Remote fetch failed - fallback to local cache if present
      final hasCache = await _localDataSource.hasCachedData();
      if (hasCache) {
        final cached = await _localDataSource.getCachedCourses();
        return cached.map((c) => c.toEntity()).toList();
      }
      rethrow;
    } catch (e) {
      final hasCache = await _localDataSource.hasCachedData();
      if (hasCache) {
        final cached = await _localDataSource.getCachedCourses();
        return cached.map((c) => c.toEntity()).toList();
      }
      throw ServerFailure('Unable to load courses: $e');
    }
  }

  @override
  Future<Course> getCourseById(int courseId) async {
    // Check local cache first for latest user progress
    final cached = await _localDataSource.getCachedCourse(courseId);
    if (cached != null && cached.lessons.isNotEmpty) {
      return cached.toEntity();
    }

    // Otherwise fetch details from remote
    final remoteCourse = await _remoteDataSource.fetchCourseDetails(courseId);
    await _localDataSource.saveCourse(remoteCourse);
    return remoteCourse.toEntity();
  }

  @override
  Future<Course> toggleLessonCompletion({
    required int courseId,
    required int lessonId,
  }) async {
    CourseModel? courseModel = await _localDataSource.getCachedCourse(courseId);

    if (courseModel == null || courseModel.lessons.isEmpty) {
      courseModel = await _remoteDataSource.fetchCourseDetails(courseId);
    }

    bool newStatus = false;
    final updatedLessons = courseModel.lessons.map((lesson) {
      if (lesson.id == lessonId) {
        newStatus = !lesson.isCompleted;
        return lesson.toEntity().copyWith(isCompleted: newStatus);
      }
      return lesson.toEntity();
    }).toList();

    final completedCount = updatedLessons.where((l) => l.isCompleted).length;
    final totalCount = updatedLessons.length;
    final newProgress = ProgressCalculator.calculate(
      completedLessons: completedCount,
      totalLessons: totalCount,
    );

    final updatedCourseEntity = courseModel.toEntity().copyWith(
      progress: newProgress,
      lessons: updatedLessons,
    );

    final updatedCourseModel = CourseModel.fromEntity(updatedCourseEntity);
    await _localDataSource.saveCourse(updatedCourseModel);

    // Sync to remote if online; otherwise enqueue mutation for later synchronization
    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      try {
        await _remoteDataSource.syncLessonProgress(
          courseId: courseId,
          lessonId: lessonId,
          isCompleted: newStatus,
        );
      } catch (_) {
        await _localDataSource.enqueueMutation(
          LessonProgressMutation.create(
            courseId: courseId,
            lessonId: lessonId,
            isCompleted: newStatus,
          ),
        );
      }
    } else {
      await _localDataSource.enqueueMutation(
        LessonProgressMutation.create(
          courseId: courseId,
          lessonId: lessonId,
          isCompleted: newStatus,
        ),
      );
    }

    return updatedCourseEntity;
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clear();
    await _localDataSource.clearMutations();
  }
}
