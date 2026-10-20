import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/thought_repository.dart';
import 'data/services/database_service.dart';
import 'features/home/view_models/home_view_model.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/settings/view_models/settings_view_model.dart';
import 'features/thoughts/view_models/thoughts_view_model.dart';
import 'navigation/main_navigation.dart';

/// Root application widget for Thovario.
class ThovarioApp extends StatelessWidget {
  final SharedPreferences prefs;
  final bool hasCompletedOnboarding;
  final ThoughtRepository? thoughtRepository;

  const ThovarioApp({
    super.key,
    required this.prefs,
    required this.hasCompletedOnboarding,
    this.thoughtRepository,
  });

  @override
  Widget build(BuildContext context) {
    final repository =
        thoughtRepository ??
        ThoughtRepository(databaseService: DatabaseService());

    return MultiProvider(
      providers: [
        Provider<ThoughtRepository>.value(value: repository),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) =>
              SettingsViewModel(prefs: prefs, thoughtRepository: repository),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(thoughtRepository: repository),
        ),
        ChangeNotifierProvider<ThoughtsViewModel>(
          create: (context) => ThoughtsViewModel(thoughtRepository: repository),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVm, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsVm.themeMode,
            home: hasCompletedOnboarding
                ? const MainNavigation()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
