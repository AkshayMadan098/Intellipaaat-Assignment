import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project/core/errors/failures.dart';
import 'package:new_project/data/datasources/course_local_datasource.dart';
import 'package:new_project/data/datasources/course_remote_datasource.dart';
import 'package:new_project/data/repositories/course_repository_impl.dart';
import '../helpers/mock_network_info.dart';

void main() {
  late CourseRemoteDataSource remoteDataSource;
  late CourseLocalDataSource localDataSource;
  late TestNetworkInfo networkInfo;
  late CourseRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    remoteDataSource = CourseRemoteDataSourceImpl();
    localDataSource = CourseLocalDataSourceImpl(prefs);
    networkInfo = TestNetworkInfo(isConnected: true);
    repository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  tearDown(() {
    networkInfo.dispose();
  });

  group('CourseRepositoryImpl', () {
    test('fetches courses from remote data source and caches them locally when online', () async {
      final courses = await repository.getCourses();

      expect(courses, isNotEmpty);
      expect(courses.length, equals(3));
      expect(courses.first.title, equals('Python Programming'));

      final hasCache = await localDataSource.hasCachedData();
      expect(hasCache, isTrue);

      final cachedCourses = await localDataSource.getCachedCourses();
      expect(cachedCourses.length, equals(3));
    });

    test('serves cached courses when network connection is offline', () async {
      await repository.getCourses();

      networkInfo.setConnected(false);
      final isOnline = await repository.isConnected;
      expect(isOnline, isFalse);

      final offlineCourses = await repository.getCourses();
      expect(offlineCourses, isNotEmpty);
      expect(offlineCourses.length, equals(3));
      expect(offlineCourses.first.title, equals('Python Programming'));
    });

    test('throws NetworkFailure when offline and no cache is present', () async {
      await localDataSource.clear();
      networkInfo.setConnected(false);

      expect(
        () => repository.getCourses(),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('enqueues lesson completion mutation when offline and flushes to remote upon sync', () async {
      // 1. Initial online fetch
      await repository.getCourses();

      // 2. Go offline
      networkInfo.setConnected(false);

      // 3. Mark lesson completed while offline (id: 114 is initially false)
      await repository.toggleLessonCompletion(courseId: 1, lessonId: 114);

      // 4. Verify mutation was placed into persistent offline queue
      final pendingCount = await repository.pendingMutationsCount;
      expect(pendingCount, equals(1));

      // 5. Reconnect to network
      networkInfo.setConnected(true);

      // 6. Trigger sync
      await repository.syncPendingMutations();

      // 7. Verify queue is now drained
      final remainingMutations = await repository.pendingMutationsCount;
      expect(remainingMutations, equals(0));

      // 8. Verify remote data source now has updated lesson status!
      final remoteCourse = await remoteDataSource.fetchCourseDetails(1);
      expect(remoteCourse.lessons.firstWhere((l) => l.id == 114).isCompleted, isTrue);
    });
  });
}
