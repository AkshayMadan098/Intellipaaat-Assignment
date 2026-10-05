import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/failures.dart';
import '../models/course_model.dart';
import '../models/lesson_progress_mutation.dart';

abstract class CourseLocalDataSource {
  Future<List<CourseModel>> getCachedCourses();
  Future<void> cacheCourses(List<CourseModel> courses);
  Future<CourseModel?> getCachedCourse(int courseId);
  Future<void> saveCourse(CourseModel course);
  Future<bool> hasCachedData();
  Future<void> clear();

  // Offline Mutation Queue
  Future<void> enqueueMutation(LessonProgressMutation mutation);
  Future<List<LessonProgressMutation>> getPendingMutations();
  Future<void> removeMutation(String mutationId);
  Future<void> clearMutations();
}

class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  static const _kCoursesKey = 'cached_courses_list_v1';
  static const _kMutationsKey = 'pending_lesson_mutations_v1';

  final SharedPreferences _prefs;

  CourseLocalDataSourceImpl(this._prefs);

  @override
  Future<List<CourseModel>> getCachedCourses() async {
    final raw = _prefs.getString(_kCoursesKey);
    if (raw == null || raw.isEmpty) {
      throw const CacheFailure('No cached courses available.');
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to parse cached course data: $e');
    }
  }

  @override
  Future<void> cacheCourses(List<CourseModel> courses) async {
    final list = courses.map((c) => c.toJson()).toList();
    await _prefs.setString(_kCoursesKey, jsonEncode(list));
  }

  @override
  Future<CourseModel?> getCachedCourse(int courseId) async {
    try {
      final courses = await getCachedCourses();
      for (final course in courses) {
        if (course.id == courseId) {
          return course;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCourse(CourseModel course) async {
    try {
      List<CourseModel> courses = [];
      try {
        courses = await getCachedCourses();
      } catch (_) {
        courses = [];
      }

      final index = courses.indexWhere((c) => c.id == course.id);
      if (index >= 0) {
        courses[index] = course;
      } else {
        courses.add(course);
      }
      await cacheCourses(courses);
    } catch (e) {
      throw CacheFailure('Failed to save course to cache: $e');
    }
  }

  @override
  Future<bool> hasCachedData() async {
    final raw = _prefs.getString(_kCoursesKey);
    return raw != null && raw.isNotEmpty;
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_kCoursesKey);
  }

  @override
  Future<void> enqueueMutation(LessonProgressMutation mutation) async {
    final mutations = await getPendingMutations();
    // Replace any existing mutation for the same lesson with the latest state
    final index = mutations.indexWhere(
      (m) => m.courseId == mutation.courseId && m.lessonId == mutation.lessonId,
    );
    if (index >= 0) {
      mutations[index] = mutation;
    } else {
      mutations.add(mutation);
    }
    final encoded = jsonEncode(mutations.map((m) => m.toJson()).toList());
    await _prefs.setString(_kMutationsKey, encoded);
  }

  @override
  Future<List<LessonProgressMutation>> getPendingMutations() async {
    final raw = _prefs.getString(_kMutationsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => LessonProgressMutation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removeMutation(String mutationId) async {
    final mutations = await getPendingMutations();
    mutations.removeWhere((m) => m.id == mutationId);
    final encoded = jsonEncode(mutations.map((m) => m.toJson()).toList());
    await _prefs.setString(_kMutationsKey, encoded);
  }

  @override
  Future<void> clearMutations() async {
    await _prefs.remove(_kMutationsKey);
  }
}
