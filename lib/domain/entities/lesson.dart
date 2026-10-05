class Lesson {
  final int id;
  final int courseId;
  final String title;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.isCompleted = false,
  });

  Lesson copyWith({
    int? id,
    int? courseId,
    String? title,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          courseId == other.courseId &&
          title == other.title &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^ courseId.hashCode ^ title.hashCode ^ isCompleted.hashCode;
}
