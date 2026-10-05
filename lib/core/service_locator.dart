import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network/network_info.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/course_local_datasource.dart';
import '../data/datasources/course_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/course_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/course_repository.dart';
import '../domain/usecases/get_course_details_usecase.dart';
import '../domain/usecases/get_courses_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/sync_pending_mutations_usecase.dart';
import '../domain/usecases/toggle_lesson_completion_usecase.dart';

class ServiceLocator {
  ServiceLocator._();

  static late SharedPreferences sharedPreferences;
  static late NetworkInfo networkInfo;

  // Data Sources
  static late AuthLocalDataSource authLocalDataSource;
  static late AuthRemoteDataSource authRemoteDataSource;
  static late CourseLocalDataSource courseLocalDataSource;
  static late CourseRemoteDataSource courseRemoteDataSource;

  // Repositories
  static late AuthRepository authRepository;
  static late CourseRepository courseRepository;

  // Use Cases
  static late LoginUseCase loginUseCase;
  static late LogoutUseCase logoutUseCase;
  static late GetCoursesUseCase getCoursesUseCase;
  static late GetCourseDetailsUseCase getCourseDetailsUseCase;
  static late ToggleLessonCompletionUseCase toggleLessonCompletionUseCase;
  static late SyncPendingMutationsUseCase syncPendingMutationsUseCase;

  static Future<void> init({
    SharedPreferences? overridePrefs,
    NetworkInfo? overrideNetworkInfo,
    FlutterSecureStorage? overrideSecureStorage,
  }) async {
    if (overridePrefs != null) {
      sharedPreferences = overridePrefs;
    } else {
      sharedPreferences = await SharedPreferences.getInstance();
    }

    networkInfo = overrideNetworkInfo ?? NetworkInfoImpl();

    // Data Sources
    authLocalDataSource = AuthLocalDataSourceImpl(overrideSecureStorage);
    authRemoteDataSource = AuthRemoteDataSourceImpl();
    courseLocalDataSource = CourseLocalDataSourceImpl(sharedPreferences);
    courseRemoteDataSource = CourseRemoteDataSourceImpl();

    // Repositories
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    courseRepository = CourseRepositoryImpl(
      remoteDataSource: courseRemoteDataSource,
      localDataSource: courseLocalDataSource,
      networkInfo: networkInfo,
    );

    // Use Cases
    loginUseCase = LoginUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCoursesUseCase = GetCoursesUseCase(courseRepository);
    getCourseDetailsUseCase = GetCourseDetailsUseCase(courseRepository);
    toggleLessonCompletionUseCase = ToggleLessonCompletionUseCase(courseRepository);
    syncPendingMutationsUseCase = SyncPendingMutationsUseCase(courseRepository);
  }
}
