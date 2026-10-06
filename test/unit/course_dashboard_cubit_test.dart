import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project/data/datasources/auth_local_datasource.dart';
import 'package:new_project/data/datasources/auth_remote_datasource.dart';
import 'package:new_project/data/datasources/course_local_datasource.dart';
import 'package:new_project/data/datasources/course_remote_datasource.dart';
import 'package:new_project/data/repositories/auth_repository_impl.dart';
import 'package:new_project/data/repositories/course_repository_impl.dart';
import 'package:new_project/domain/usecases/get_courses_usecase.dart';
import 'package:new_project/domain/usecases/logout_usecase.dart';
import 'package:new_project/domain/usecases/sync_pending_mutations_usecase.dart';
import 'package:new_project/presentation/cubits/dashboard/course_dashboard_cubit.dart';
import 'package:new_project/presentation/cubits/dashboard/course_dashboard_state.dart';
import '../helpers/mock_network_info.dart';

void main() {
  late CourseRemoteDataSource remoteDataSource;
  late CourseLocalDataSource localDataSource;
  late TestNetworkInfo networkInfo;
  late CourseRepositoryImpl courseRepository;
  late AuthRepositoryImpl authRepository;
  late GetCoursesUseCase getCoursesUseCase;
  late LogoutUseCase logoutUseCase;
  late SyncPendingMutationsUseCase syncPendingMutationsUseCase;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    remoteDataSource = CourseRemoteDataSourceImpl();
    localDataSource = CourseLocalDataSourceImpl(prefs);
    networkInfo = TestNetworkInfo(isConnected: true);
    courseRepository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
    FlutterSecureStorage.setMockInitialValues({});
    authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(),
      localDataSource: AuthLocalDataSourceImpl(const FlutterSecureStorage()),
    );
    getCoursesUseCase = GetCoursesUseCase(courseRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    syncPendingMutationsUseCase = SyncPendingMutationsUseCase(courseRepository);
  });

  tearDown(() {
    networkInfo.dispose();
  });

  group('CourseDashboardCubit', () {
    test('initial state is CourseDashboardInitial', () {
      final cubit = CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      );
      expect(cubit.state, equals(const CourseDashboardInitial()));
    });

    blocTest<CourseDashboardCubit, CourseDashboardState>(
      'emits [CourseDashboardLoading, CourseDashboardLoaded] on successful fetch',
      build: () => CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      ),
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        const CourseDashboardLoading(isOffline: false),
        isA<CourseDashboardLoaded>()
            .having((s) => s.courses.length, 'courses.length', 3)
            .having((s) => s.isOffline, 'isOffline', false)
            .having((s) => s.courses.first.title, 'first course', 'Python Programming'),
      ],
    );

    blocTest<CourseDashboardCubit, CourseDashboardState>(
      'emits [CourseDashboardLoading, CourseDashboardEmpty] when no courses exist',
      setUp: () => remoteDataSource.setSimulatedEmpty(true),
      build: () => CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      ),
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        const CourseDashboardLoading(isOffline: false),
        const CourseDashboardEmpty(isOffline: false),
      ],
    );

    blocTest<CourseDashboardCubit, CourseDashboardState>(
      'emits [CourseDashboardLoading, CourseDashboardError] when remote service fails',
      setUp: () => remoteDataSource.setSimulatedError(true),
      build: () => CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      ),
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        const CourseDashboardLoading(isOffline: false),
        isA<CourseDashboardError>()
            .having((s) => s.message, 'error message', contains('Internal server error')),
      ],
    );

    blocTest<CourseDashboardCubit, CourseDashboardState>(
      'reacts to network loss by updating isOffline in loaded state',
      build: () => CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      ),
      act: (cubit) async {
        await cubit.loadCourses();
        networkInfo.setConnected(false);
      },
      skip: 2, // Skip initial loading and loaded
      expect: () => [
        isA<CourseDashboardLoaded>()
            .having((s) => s.isOffline, 'isOffline', true),
      ],
    );

    blocTest<CourseDashboardCubit, CourseDashboardState>(
      'updateCourse modifies existing course progress in loaded state',
      build: () => CourseDashboardCubit(
        getCoursesUseCase: getCoursesUseCase,
        logoutUseCase: logoutUseCase,
        syncPendingMutationsUseCase: syncPendingMutationsUseCase,
        courseRepository: courseRepository,
      ),
      act: (cubit) async {
        await cubit.loadCourses();
        final loadedState = cubit.state as CourseDashboardLoaded;
        final updated = loadedState.courses.first.copyWith(progress: 85);
        cubit.updateCourse(updated);
      },
      skip: 2,
      expect: () => [
        isA<CourseDashboardLoaded>()
            .having((s) => s.courses.first.progress, 'progress', 85),
      ],
    );
  });
}
