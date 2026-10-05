import '../../domain/entities/course.dart';
import 'lesson_model.dart';

class CourseModel {
  final int id;
  final String title;
  final String instructor;
  final int progress;
  final int lessonsCount;
  final List<LessonModel> lessons;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.lessonsCount,
    this.lessons = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    int parsedLessonsCount = 0;
    List<LessonModel> parsedLessons = [];

    final rawLessons = json['lessons'];
    if (rawLessons is int) {
      parsedLessonsCount = rawLessons;
    } else if (rawLessons is List) {
      parsedLessons = rawLessons
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>, defaultCourseId: json['id'] as int?))
          .toList();
      parsedLessonsCount = parsedLessons.length;
    }

    if (json['lesson_items'] is List) {
      parsedLessons = (json['lesson_items'] as List)
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>, defaultCourseId: json['id'] as int?))
          .toList();
    }

    if (json['lessons_count'] is int) {
      parsedLessonsCount = json['lessons_count'] as int;
    }

    if (parsedLessonsCount == 0 && parsedLessons.isNotEmpty) {
      parsedLessonsCount = parsedLessons.length;
    }

    return CourseModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      lessonsCount: parsedLessonsCount,
      lessons: parsedLessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'progress': progress,
      'lessons_count': lessonsCount,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  Course toEntity() {
    return Course(
      id: id,
      title: title,
      instructor: instructor,
      progress: progress,
      lessonsCount: lessonsCount,
      lessons: lessons.map((l) => l.toEntity()).toList(),
    );
  }

  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      title: course.title,
      instructor: course.instructor,
      progress: course.progress,
      lessonsCount: course.lessonsCount,
      lessons: course.lessons.map((l) => LessonModel.fromEntity(l)).toList(),
    );
  }
}
