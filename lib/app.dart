import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'models/onboarding_data.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/intent_screen.dart';
import 'screens/onboarding/goal_screen.dart';
import 'screens/onboarding/quiz_screen.dart';
import 'screens/onboarding/photo_capture_screen.dart';
import 'screens/home/dashboard_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/intent',
      builder: (context, state) {
        final data = (state.extra as OnboardingData?) ?? const OnboardingData();
        return IntentScreen(data: data);
      },
    ),
    GoRoute(
      path: '/goal',
      builder: (context, state) {
        final data = (state.extra as OnboardingData?) ?? const OnboardingData();
        return GoalScreen(data: data);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final data = (state.extra as OnboardingData?) ?? const OnboardingData();
        return QuizScreen(data: data);
      },
    ),
    GoRoute(
      path: '/photo-capture',
      builder: (context, state) {
        final data = (state.extra as OnboardingData?) ?? const OnboardingData();
        return PhotoCaptureScreen(data: data);
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final data = (state.extra as OnboardingData?) ?? const OnboardingData();
        return DashboardScreen(data: data);
      },
    ),
  ],
);

class SkinAIApp extends StatelessWidget {
  const SkinAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SkinAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
