import '../entities/course.dart';
import '../repositories/course_repository.dart';

class ToggleLessonCompletionUseCase {
  final CourseRepository _repository;

  ToggleLessonCompletionUseCase(this._repository);

  Future<Course> execute({required int courseId, required int lessonId}) {
    return _repository.toggleLessonCompletion(
      courseId: courseId,
      lessonId: lessonId,
    );
  }
}
