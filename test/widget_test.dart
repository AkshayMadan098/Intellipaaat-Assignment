import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project/core/service_locator.dart';
import 'package:new_project/main.dart';

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await ServiceLocator.init(overridePrefs: prefs);
  });

  testWidgets('App renders LoginScreen initially with expected inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const LearningDashboardApp(isInitiallyLoggedIn: false));
    await tester.pumpAndSettle();

    // Verify Title and Subtitle exist
    expect(find.text('Learning Dashboard'), findsOneWidget);
    expect(find.text('Welcome back! Sign in to continue learning.'), findsOneWidget);

    // Verify Email and Password input labels
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify Sign In button
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Entering email and password updates text fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const LearningDashboardApp(isInitiallyLoggedIn: false));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'student@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pumpAndSettle();

    final widgets = tester.widgetList<TextField>(textFields).toList();
    expect(widgets[0].controller?.text, equals('student@example.com'));
    expect(widgets[1].controller?.text, equals('password123'));
  });
}
