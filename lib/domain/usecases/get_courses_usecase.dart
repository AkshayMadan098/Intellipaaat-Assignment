import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository _repository;

  GetCoursesUseCase(this._repository);

  Future<List<Course>> execute({bool forceRefresh = false}) {
    return _repository.getCourses(forceRefresh: forceRefresh);
  }
}
