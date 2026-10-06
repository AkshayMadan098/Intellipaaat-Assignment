import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project/data/datasources/course_local_datasource.dart';
import 'package:new_project/data/datasources/course_remote_datasource.dart';
import 'package:new_project/data/repositories/course_repository_impl.dart';
import 'package:new_project/domain/entities/course.dart';
import 'package:new_project/domain/usecases/get_course_details_usecase.dart';
import 'package:new_project/domain/usecases/toggle_lesson_completion_usecase.dart';
import 'package:new_project/presentation/cubits/details/course_details_cubit.dart';
import 'package:new_project/presentation/cubits/details/course_details_state.dart';
import '../helpers/mock_network_info.dart';

void main() {
  late CourseRepositoryImpl courseRepository;
  late GetCourseDetailsUseCase getCourseDetailsUseCase;
  late ToggleLessonCompletionUseCase toggleLessonCompletionUseCase;
  late TestNetworkInfo networkInfo;
  late Course seedCourse;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final remoteDataSource = CourseRemoteDataSourceImpl();
    final localDataSource = CourseLocalDataSourceImpl(prefs);
    networkInfo = TestNetworkInfo(isConnected: true);
    courseRepository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
    getCourseDetailsUseCase = GetCourseDetailsUseCase(courseRepository);
    toggleLessonCompletionUseCase = ToggleLessonCompletionUseCase(courseRepository);

    seedCourse = await courseRepository.getCourseById(1);
  });

  tearDown(() {
    networkInfo.dispose();
  });

  group('CourseDetailsCubit', () {
    test('initial state contains initial course', () {
      final cubit = CourseDetailsCubit(
        getCourseDetailsUseCase: getCourseDetailsUseCase,
        toggleLessonCompletionUseCase: toggleLessonCompletionUseCase,
        initialCourse: seedCourse,
      );
      expect(cubit.state, equals(CourseDetailsInitial(seedCourse)));
    });

    blocTest<CourseDetailsCubit, CourseDetailsState>(
      'toggleLesson toggles completion status and updates course progress',
      build: () => CourseDetailsCubit(
        getCourseDetailsUseCase: getCourseDetailsUseCase,
        toggleLessonCompletionUseCase: toggleLessonCompletionUseCase,
        initialCourse: seedCourse,
      ),
      act: (cubit) async {
        final pendingLesson = seedCourse.lessons.firstWhere((l) => !l.isCompleted);
        await cubit.toggleLesson(pendingLesson.id);
      },
      expect: () => [
        isA<CourseDetailsLoaded>()
            .having((s) => s.course.progress, 'progress', greaterThan(seedCourse.progress))
            .having(
              (s) => s.course.lessons.firstWhere((l) => l.id == 114).isCompleted,
              'lesson 114 is completed',
              isTrue,
            ),
      ],
    );
  });
}
