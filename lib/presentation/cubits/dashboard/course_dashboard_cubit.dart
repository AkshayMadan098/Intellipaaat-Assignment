import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/usecases/get_courses_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/sync_pending_mutations_usecase.dart';
import 'course_dashboard_state.dart';

class CourseDashboardCubit extends Cubit<CourseDashboardState> {
  final GetCoursesUseCase _getCoursesUseCase;
  final LogoutUseCase _logoutUseCase;
  final SyncPendingMutationsUseCase _syncPendingMutationsUseCase;
  final CourseRepository _courseRepository;
  StreamSubscription<bool>? _connectivitySubscription;

  CourseDashboardCubit({
    required GetCoursesUseCase getCoursesUseCase,
    required LogoutUseCase logoutUseCase,
    required SyncPendingMutationsUseCase syncPendingMutationsUseCase,
    required CourseRepository courseRepository,
  })  : _getCoursesUseCase = getCoursesUseCase,
        _logoutUseCase = logoutUseCase,
        _syncPendingMutationsUseCase = syncPendingMutationsUseCase,
        _courseRepository = courseRepository,
        super(const CourseDashboardInitial()) {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _courseRepository.onConnectivityChanged.listen((isConnected) async {
      if (isClosed) return;
      final isOffline = !isConnected;

      if (isConnected) {
        // Automatically sync pending offline changes to server when network reconnects
        await _syncPendingMutationsUseCase.execute();
      }

      if (state is CourseDashboardLoaded) {
        final loaded = state as CourseDashboardLoaded;
        emit(CourseDashboardLoaded(
          courses: loaded.courses,
          isOffline: isOffline,
        ));
        if (isConnected) {
          loadCourses(forceRefresh: true);
        }
      } else if (state is CourseDashboardError && isConnected) {
        loadCourses();
      }
    });
  }

  Future<void> loadCourses({bool forceRefresh = false}) async {
    final isOnline = await _courseRepository.isConnected;
    emit(CourseDashboardLoading(isOffline: !isOnline));

    try {
      final courses = await _getCoursesUseCase.execute(forceRefresh: forceRefresh);
      final currentOnline = await _courseRepository.isConnected;
      if (courses.isEmpty) {
        emit(CourseDashboardEmpty(isOffline: !currentOnline));
      } else {
        emit(CourseDashboardLoaded(
          courses: courses,
          isOffline: !currentOnline,
        ));
      }
    } on Failure catch (e) {
      final currentOnline = await _courseRepository.isConnected;
      emit(CourseDashboardError(
        message: e.message,
        isOffline: !currentOnline,
      ));
    } catch (e) {
      final currentOnline = await _courseRepository.isConnected;
      emit(CourseDashboardError(
        message: 'Unexpected error: $e',
        isOffline: !currentOnline,
      ));
    }
  }

  void updateCourse(Course updatedCourse) {
    if (state is CourseDashboardLoaded) {
      final loaded = state as CourseDashboardLoaded;
      final index = loaded.courses.indexWhere((c) => c.id == updatedCourse.id);
      if (index >= 0) {
        final updatedList = List<Course>.from(loaded.courses);
        updatedList[index] = updatedCourse;
        emit(CourseDashboardLoaded(
          courses: updatedList,
          isOffline: loaded.isOffline,
        ));
      }
    }
  }

  Future<void> clearCache() async {
    await _courseRepository.clearCache();
    await loadCourses(forceRefresh: true);
  }

  Future<void> logout() async {
    await _logoutUseCase.execute();
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
