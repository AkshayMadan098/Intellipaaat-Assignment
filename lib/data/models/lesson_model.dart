import '../../domain/entities/lesson.dart';

class LessonModel {
  final int id;
  final int courseId;
  final String title;
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json, {int? defaultCourseId}) {
    return LessonModel(
      id: json['id'] as int? ?? 0,
      courseId: (json['course_id'] ?? json['courseId'] ?? defaultCourseId ?? 0) as int,
      title: json['title'] as String? ?? '',
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'is_completed': isCompleted,
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      isCompleted: isCompleted,
    );
  }

  factory LessonModel.fromEntity(Lesson lesson) {
    return LessonModel(
      id: lesson.id,
      courseId: lesson.courseId,
      title: lesson.title,
      isCompleted: lesson.isCompleted,
    );
  }
}
