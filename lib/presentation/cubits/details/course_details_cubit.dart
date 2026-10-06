import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/usecases/get_course_details_usecase.dart';
import '../../../domain/usecases/toggle_lesson_completion_usecase.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final GetCourseDetailsUseCase _getCourseDetailsUseCase;
  final ToggleLessonCompletionUseCase _toggleLessonCompletionUseCase;

  CourseDetailsCubit({
    required GetCourseDetailsUseCase getCourseDetailsUseCase,
    required ToggleLessonCompletionUseCase toggleLessonCompletionUseCase,
    required Course initialCourse,
  })  : _getCourseDetailsUseCase = getCourseDetailsUseCase,
        _toggleLessonCompletionUseCase = toggleLessonCompletionUseCase,
        super(CourseDetailsInitial(initialCourse));

  Future<void> loadDetails() async {
    if (state.course.lessons.isEmpty) {
      emit(CourseDetailsLoading(state.course));
    }

    try {
      final detailedCourse = await _getCourseDetailsUseCase.execute(state.course.id);
      emit(CourseDetailsLoaded(detailedCourse));
    } on Failure catch (e) {
      emit(CourseDetailsError(state.course, e.message));
    } catch (e) {
      emit(CourseDetailsError(state.course, 'Failed to load course details: $e'));
    }
  }

  Future<Course> toggleLesson(int lessonId) async {
    try {
      final updated = await _toggleLessonCompletionUseCase.execute(
        courseId: state.course.id,
        lessonId: lessonId,
      );
      emit(CourseDetailsLoaded(updated));
      return updated;
    } on Failure catch (e) {
      emit(CourseDetailsError(state.course, e.message));
      return state.course;
    } catch (e) {
      emit(CourseDetailsError(state.course, 'Could not update lesson status: $e'));
      return state.course;
    }
  }
}
