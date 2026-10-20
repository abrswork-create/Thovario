import 'package:flutter/material.dart';
import '../../data/models/thought.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/thoughts/screens/thought_detail_screen.dart';
import '../../features/thoughts/screens/thoughts_screen.dart';
import '../../features/write/screens/write_screen.dart';
import '../../navigation/main_navigation.dart';

/// Central application route definitions and navigation helpers.
class AppRouter {
  AppRouter._();

  static const String onboarding = '/onboarding';
  static const String main = '/';
  static const String home = '/home';
  static const String thoughts = '/thoughts';
  static const String write = '/write';
  static const String detail = '/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case thoughts:
        return MaterialPageRoute(builder: (_) => const ThoughtsScreen());
      case write:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WriteScreen(
            thoughtToEdit: args?['thought'] as Thought?,
            initialPrompt: args?['prompt'] as String?,
          ),
        );
      case detail:
        final thought = settings.arguments as Thought;
        return MaterialPageRoute(
          builder: (_) => ThoughtDetailScreen(thought: thought),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
    }
  }
}
