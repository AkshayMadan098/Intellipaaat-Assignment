import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCourseDetailsUseCase {
  final CourseRepository _repository;

  GetCourseDetailsUseCase(this._repository);

  Future<Course> execute(int courseId) {
    return _repository.getCourseById(courseId);
  }
}
