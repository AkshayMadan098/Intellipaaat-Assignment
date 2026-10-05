class LessonProgressMutation {
  final String id;
  final int courseId;
  final int lessonId;
  final bool isCompleted;
  final int timestamp;

  const LessonProgressMutation({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.isCompleted,
    required this.timestamp,
  });

  factory LessonProgressMutation.create({
    required int courseId,
    required int lessonId,
    required bool isCompleted,
  }) {
    return LessonProgressMutation(
      id: '${courseId}_${lessonId}_${DateTime.now().millisecondsSinceEpoch}',
      courseId: courseId,
      lessonId: lessonId,
      isCompleted: isCompleted,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory LessonProgressMutation.fromJson(Map<String, dynamic> json) {
    return LessonProgressMutation(
      id: json['id'] as String,
      courseId: json['course_id'] as int,
      lessonId: json['lesson_id'] as int,
      isCompleted: json['is_completed'] as bool,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'lesson_id': lessonId,
      'is_completed': isCompleted,
      'timestamp': timestamp,
    };
  }
}
