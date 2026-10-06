import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../cubits/dashboard/course_dashboard_cubit.dart';
import '../../cubits/dashboard/course_dashboard_state.dart';
import '../../widgets/offline_banner.dart';
import '../details/course_details_screen.dart';
import '../login/login_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';

class CourseDashboardScreen extends StatelessWidget {
  const CourseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDashboardCubit(
        getCoursesUseCase: ServiceLocator.getCoursesUseCase,
        logoutUseCase: ServiceLocator.logoutUseCase,
        syncPendingMutationsUseCase: ServiceLocator.syncPendingMutationsUseCase,
        courseRepository: ServiceLocator.courseRepository,
      )..loadCourses(),
      child: const _CourseDashboardView(),
    );
  }
}

class _CourseDashboardView extends StatelessWidget {
  const _CourseDashboardView();

  void _navigateToCourseDetails(BuildContext context, Course course) async {
    final cubit = context.read<CourseDashboardCubit>();
    final updatedCourse = await Navigator.of(context).push<Course?>(
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(initialCourse: course),
      ),
    );

    if (updatedCourse != null) {
      cubit.updateCourse(updatedCourse);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final cubit = context.read<CourseDashboardCubit>();
    await cubit.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDashboardCubit, CourseDashboardState>(
      builder: (context, state) {
        final cubit = context.read<CourseDashboardCubit>();
        final isOffline = state.isOffline;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Courses'),
            actions: [
              if (isOffline)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 20,
                    color: AppTheme.warningColor,
                  ),
                ),
              // Menu with options to clear cache and logout
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) async {
                  switch (value) {
                    case 'clear_cache':
                      await cubit.clearCache();
                      break;
                    case 'logout':
                      await _handleLogout(context);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'clear_cache',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Clear Local Cache'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              if (isOffline) const OfflineBanner(),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CourseDashboardState state) {
    final cubit = context.read<CourseDashboardCubit>();

    if (state is CourseDashboardLoading || state is CourseDashboardInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your courses...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CourseDashboardError) {
      return ErrorView(
        message: state.message,
        isOffline: state.isOffline,
        onRetry: () => cubit.loadCourses(forceRefresh: true),
      );
    }

    if (state is CourseDashboardEmpty) {
      return EmptyView(
        onRefresh: () => cubit.loadCourses(forceRefresh: true),
      );
    }

    if (state is CourseDashboardLoaded) {
      return RefreshIndicator(
        onRefresh: () => cubit.loadCourses(forceRefresh: true),
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: state.courses.length,
          itemBuilder: (context, index) {
            final course = state.courses[index];
            return CourseCard(
              course: course,
              onContinue: () => _navigateToCourseDetails(context, course),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
