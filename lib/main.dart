import 'package:flutter/material.dart';
import 'core/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard/course_dashboard_screen.dart';
import 'presentation/screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  final isLoggedIn = await ServiceLocator.authRepository.isLoggedIn();

  runApp(LearningDashboardApp(isInitiallyLoggedIn: isLoggedIn));
}

class LearningDashboardApp extends StatelessWidget {
  final bool isInitiallyLoggedIn;

  const LearningDashboardApp({
    super.key,
    required this.isInitiallyLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isInitiallyLoggedIn
          ? const CourseDashboardScreen()
          : const LoginScreen(),
    );
  }
}
