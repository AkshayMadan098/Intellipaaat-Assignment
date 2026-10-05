import 'lesson.dart';

class Course {
  final int id;
  final String title;
  final String instructor;
  final int progress;
  final int lessonsCount;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.lessonsCount,
    this.lessons = const [],
  });

  int get completedLessonsCount =>
      lessons.where((lesson) => lesson.isCompleted).length;

  Course copyWith({
    int? id,
    String? title,
    String? instructor,
    int? progress,
    int? lessonsCount,
    List<Lesson>? lessons,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      progress: progress ?? this.progress,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          instructor == other.instructor &&
          progress == other.progress &&
          lessonsCount == other.lessonsCount;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      instructor.hashCode ^
      progress.hashCode ^
      lessonsCount.hashCode;
}
