import 'dart:async';
import '../../core/errors/failures.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> fetchCourses();
  Future<CourseModel> fetchCourseDetails(int courseId);
  Future<void> syncLessonProgress({
    required int courseId,
    required int lessonId,
    required bool isCompleted,
  });
  void setSimulatedError(bool shouldFail);
  bool get isSimulatedError;
  void setSimulatedEmpty(bool isEmpty);
  bool get isSimulatedEmpty;
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  bool _simulatedError = false;
  bool _simulatedEmpty = false;

  @override
  bool get isSimulatedError => _simulatedError;

  @override
  void setSimulatedError(bool shouldFail) {
    _simulatedError = shouldFail;
  }

  @override
  bool get isSimulatedEmpty => _simulatedEmpty;

  @override
  void setSimulatedEmpty(bool isEmpty) {
    _simulatedEmpty = isEmpty;
  }

  /// Initial seed dataset matching the project specification
  static final List<CourseModel> _initialSeedCourses = [
    CourseModel(
      id: 1,
      title: 'Python Programming',
      instructor: 'John Smith',
      progress: 65,
      lessonsCount: 20,
      lessons: [
        const LessonModel(id: 101, courseId: 1, title: 'Introduction', isCompleted: true),
        const LessonModel(id: 102, courseId: 1, title: 'Variables & Data Types', isCompleted: true),
        const LessonModel(id: 103, courseId: 1, title: 'Control Flow & Conditionals', isCompleted: true),
        const LessonModel(id: 104, courseId: 1, title: 'Loops & Iterations', isCompleted: true),
        const LessonModel(id: 105, courseId: 1, title: 'Lists, Tuples & Dictionaries', isCompleted: true),
        const LessonModel(id: 106, courseId: 1, title: 'Strings & Text Formatting', isCompleted: true),
        const LessonModel(id: 107, courseId: 1, title: 'Functions & Scope', isCompleted: true),
        const LessonModel(id: 108, courseId: 1, title: 'Modules & Packages', isCompleted: true),
        const LessonModel(id: 109, courseId: 1, title: 'File Input & Output', isCompleted: true),
        const LessonModel(id: 110, courseId: 1, title: 'Exception Handling', isCompleted: true),
        const LessonModel(id: 111, courseId: 1, title: 'List Comprehensions', isCompleted: true),
        const LessonModel(id: 112, courseId: 1, title: 'Object-Oriented Basics', isCompleted: true),
        const LessonModel(id: 113, courseId: 1, title: 'Classes, Attributes & Methods', isCompleted: true),
        const LessonModel(id: 114, courseId: 1, title: 'Functions', isCompleted: false),
        const LessonModel(id: 115, courseId: 1, title: 'OOP', isCompleted: false),
        const LessonModel(id: 116, courseId: 1, title: 'Decorators & Generators', isCompleted: false),
        const LessonModel(id: 117, courseId: 1, title: 'Working with JSON & APIs', isCompleted: false),
        const LessonModel(id: 118, courseId: 1, title: 'Virtual Environments & Pip', isCompleted: false),
        const LessonModel(id: 119, courseId: 1, title: 'Unit Testing with PyTest', isCompleted: false),
        const LessonModel(id: 120, courseId: 1, title: 'Capstone Project', isCompleted: false),
      ],
    ),
    CourseModel(
      id: 2,
      title: 'Generative AI',
      instructor: 'Sarah Williams',
      progress: 40,
      lessonsCount: 16,
      lessons: [
        const LessonModel(id: 201, courseId: 2, title: 'Introduction to GenAI', isCompleted: true),
        const LessonModel(id: 202, courseId: 2, title: 'Transformer Architecture & Attention', isCompleted: true),
        const LessonModel(id: 203, courseId: 2, title: 'Tokenization & Embeddings', isCompleted: true),
        const LessonModel(id: 204, courseId: 2, title: 'Prompt Engineering Fundamentals', isCompleted: true),
        const LessonModel(id: 205, courseId: 2, title: 'Few-Shot & Chain-of-Thought Prompting', isCompleted: true),
        const LessonModel(id: 206, courseId: 2, title: 'Working with LLM APIs', isCompleted: true),
        const LessonModel(id: 207, courseId: 2, title: 'Vector Databases & Similarity Search', isCompleted: false),
        const LessonModel(id: 208, courseId: 2, title: 'Retrieval Augmented Generation (RAG)', isCompleted: false),
        const LessonModel(id: 209, courseId: 2, title: 'Chunking Strategies & Document Ingestion', isCompleted: false),
        const LessonModel(id: 210, courseId: 2, title: 'Fine-Tuning vs Pre-training', isCompleted: false),
        const LessonModel(id: 211, courseId: 2, title: 'Parameter-Efficient Fine-Tuning (PEFT/LoRA)', isCompleted: false),
        const LessonModel(id: 212, courseId: 2, title: 'AI Agent Architecture & Tool Use', isCompleted: false),
        const LessonModel(id: 213, courseId: 2, title: 'Evaluation Metrics for LLMs', isCompleted: false),
        const LessonModel(id: 214, courseId: 2, title: 'Safety, Guardrails & Jailbreaking', isCompleted: false),
        const LessonModel(id: 215, courseId: 2, title: 'Multimodal AI Models', isCompleted: false),
        const LessonModel(id: 216, courseId: 2, title: 'Production Deployment & Monitoring', isCompleted: false),
      ],
    ),
    CourseModel(
      id: 3,
      title: 'Full Stack Development',
      instructor: 'David Brown',
      progress: 25,
      lessonsCount: 28,
      lessons: [
        const LessonModel(id: 301, courseId: 3, title: 'Web Architecture & HTTP Protocols', isCompleted: true),
        const LessonModel(id: 302, courseId: 3, title: 'Modern HTML5 Semantic Standards', isCompleted: true),
        const LessonModel(id: 303, courseId: 3, title: 'CSS3 Flexbox & Grid Systems', isCompleted: true),
        const LessonModel(id: 304, courseId: 3, title: 'JavaScript ES6+ Syntax & Features', isCompleted: true),
        const LessonModel(id: 305, courseId: 3, title: 'Asynchronous JS: Promises & Async/Await', isCompleted: true),
        const LessonModel(id: 306, courseId: 3, title: 'DOM Manipulation & Browser Events', isCompleted: true),
        const LessonModel(id: 307, courseId: 3, title: 'Git Version Control & Collaboration', isCompleted: true),
        const LessonModel(id: 308, courseId: 3, title: 'Introduction to React & Component Lifecycle', isCompleted: false),
        const LessonModel(id: 309, courseId: 3, title: 'State Management & Hooks', isCompleted: false),
        const LessonModel(id: 310, courseId: 3, title: 'Node.js Runtime & NPM Ecosystem', isCompleted: false),
        const LessonModel(id: 311, courseId: 3, title: 'Express.js RESTful API Design', isCompleted: false),
        const LessonModel(id: 312, courseId: 3, title: 'Middleware & Error Handling', isCompleted: false),
        const LessonModel(id: 313, courseId: 3, title: 'Relational Databases with PostgreSQL', isCompleted: false),
        const LessonModel(id: 314, courseId: 3, title: 'ORM & Query Builders (Prisma)', isCompleted: false),
        const LessonModel(id: 315, courseId: 3, title: 'Document Databases with MongoDB', isCompleted: false),
        const LessonModel(id: 316, courseId: 3, title: 'Authentication with JWT & OAuth 2.0', isCompleted: false),
        const LessonModel(id: 317, courseId: 3, title: 'Password Hashing & Security Best Practices', isCompleted: false),
        const LessonModel(id: 318, courseId: 3, title: 'State Management with Redux/Zustand', isCompleted: false),
        const LessonModel(id: 319, courseId: 3, title: 'Real-Time Communication with WebSockets', isCompleted: false),
        const LessonModel(id: 320, courseId: 3, title: 'Unit & Integration Testing (Jest)', isCompleted: false),
        const LessonModel(id: 321, courseId: 3, title: 'End-to-End Testing with Playwright', isCompleted: false),
        const LessonModel(id: 322, courseId: 3, title: 'Containerization with Docker', isCompleted: false),
        const LessonModel(id: 323, courseId: 3, title: 'CI/CD Pipelines with GitHub Actions', isCompleted: false),
        const LessonModel(id: 324, courseId: 3, title: 'Cloud Hosting on AWS / GCP', isCompleted: false),
        const LessonModel(id: 325, courseId: 3, title: 'Serverless Functions & Edge Computing', isCompleted: false),
        const LessonModel(id: 326, courseId: 3, title: 'Caching Strategies with Redis', isCompleted: false),
        const LessonModel(id: 327, courseId: 3, title: 'Performance Optimization & Lighthouse', isCompleted: false),
        const LessonModel(id: 328, courseId: 3, title: 'Full Stack Capstone Deployment', isCompleted: false),
      ],
    ),
  ];

  @override
  Future<List<CourseModel>> fetchCourses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 650));

    if (_simulatedError) {
      throw const ServerFailure('HTTP 500: Internal server error while fetching courses.');
    }

    if (_simulatedEmpty) {
      return [];
    }

    return _initialSeedCourses;
  }

  @override
  Future<CourseModel> fetchCourseDetails(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (_simulatedError) {
      throw const ServerFailure('HTTP 500: Could not fetch course details.');
    }

    final course = _initialSeedCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw const ServerFailure('Course not found.'),
    );

    return course;
  }

  @override
  Future<void> syncLessonProgress({
    required int courseId,
    required int lessonId,
    required bool isCompleted,
  }) async {
    // Simulate network round-trip to persist progress on server
    await Future.delayed(const Duration(milliseconds: 150));

    final courseIndex = _initialSeedCourses.indexWhere((c) => c.id == courseId);
    if (courseIndex >= 0) {
      final course = _initialSeedCourses[courseIndex];
      final updatedLessons = course.lessons.map((l) {
        if (l.id == lessonId) {
          return LessonModel(
            id: l.id,
            courseId: l.courseId,
            title: l.title,
            isCompleted: isCompleted,
          );
        }
        return l;
      }).toList();

      final completedCount = updatedLessons.where((l) => l.isCompleted).length;
      final totalCount = updatedLessons.length;
      final newProgress = totalCount > 0 ? ((completedCount / totalCount) * 100).round() : 0;

      _initialSeedCourses[courseIndex] = CourseModel(
        id: course.id,
        title: course.title,
        instructor: course.instructor,
        progress: newProgress,
        lessonsCount: course.lessonsCount,
        lessons: updatedLessons,
      );
    }
  }
}
