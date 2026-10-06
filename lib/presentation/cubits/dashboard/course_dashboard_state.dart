import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';

abstract class CourseDashboardState extends Equatable {
  final bool isOffline;

  const CourseDashboardState({this.isOffline = false});

  @override
  List<Object?> get props => [isOffline];
}

class CourseDashboardInitial extends CourseDashboardState {
  const CourseDashboardInitial();
}

class CourseDashboardLoading extends CourseDashboardState {
  const CourseDashboardLoading({super.isOffline});
}

class CourseDashboardLoaded extends CourseDashboardState {
  final List<Course> courses;

  const CourseDashboardLoaded({
    required this.courses,
    super.isOffline,
  });

  @override
  List<Object?> get props => [courses, isOffline];
}

class CourseDashboardEmpty extends CourseDashboardState {
  const CourseDashboardEmpty({super.isOffline});
}

class CourseDashboardError extends CourseDashboardState {
  final String message;

  const CourseDashboardError({
    required this.message,
    super.isOffline,
  });

  @override
  List<Object?> get props => [message, isOffline];
}
