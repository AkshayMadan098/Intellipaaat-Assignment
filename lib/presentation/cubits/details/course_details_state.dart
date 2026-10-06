import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';

abstract class CourseDetailsState extends Equatable {
  final Course course;

  const CourseDetailsState(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseDetailsInitial extends CourseDetailsState {
  const CourseDetailsInitial(super.course);
}

class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading(super.course);
}

class CourseDetailsLoaded extends CourseDetailsState {
  const CourseDetailsLoaded(super.course);
}

class CourseDetailsError extends CourseDetailsState {
  final String message;

  const CourseDetailsError(super.course, this.message);

  @override
  List<Object?> get props => [course, message];
}
