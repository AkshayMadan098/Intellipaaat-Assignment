import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../cubits/details/course_details_cubit.dart';
import '../../cubits/details/course_details_state.dart';
import 'widgets/lesson_tile.dart';
import 'widgets/progress_header.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course initialCourse;

  const CourseDetailsScreen({super.key, required this.initialCourse});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailsCubit(
        getCourseDetailsUseCase: ServiceLocator.getCourseDetailsUseCase,
        toggleLessonCompletionUseCase: ServiceLocator.toggleLessonCompletionUseCase,
        initialCourse: initialCourse,
      )..loadDetails(),
      child: const _CourseDetailsView(),
    );
  }
}

class _CourseDetailsView extends StatelessWidget {
  const _CourseDetailsView();

  void _handleBack(BuildContext context) {
    final cubit = context.read<CourseDetailsCubit>();
    Navigator.of(context).pop(cubit.state.course);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        final cubit = context.read<CourseDetailsCubit>();
        final course = state.course;
        final lessons = course.lessons;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.of(context).pop(state.course);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Course Details'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => _handleBack(context),
              ),
            ),
            body: state is CourseDetailsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Header with Course Title & Progress
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: ProgressHeader(course: course),
                        ),
                      ),
                      // Section Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Curriculum Lessons',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${course.completedLessonsCount}/${lessons.length} Done',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Lessons List
                      if (lessons.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No lessons available for this course.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final lesson = lessons[index];
                              return LessonTile(
                                lesson: lesson,
                                index: index + 1,
                                onToggle: () => cubit.toggleLesson(lesson.id),
                              );
                            },
                            childCount: lessons.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
