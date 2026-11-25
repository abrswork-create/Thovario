import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/lock_screen.dart';
import 'data/repositories/thought_repository.dart';
import 'data/services/database_service.dart';
import 'features/home/view_models/home_view_model.dart';
import 'features/insights/view_models/insights_view_model.dart';
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
        ChangeNotifierProvider<InsightsViewModel>(
          create: (context) => InsightsViewModel(thoughtRepository: repository),
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
            home: _AuthGate(
              child: hasCompletedOnboarding
                  ? const MainNavigation()
                  : const OnboardingScreen(),
            ),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  final Widget child;
  const _AuthGate({required this.child});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final settingsVm = context.read<SettingsViewModel>();
    if (settingsVm.isBiometricEnabled) {
      _isLocked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      final settingsVm = context.read<SettingsViewModel>();
      if (settingsVm.isBiometricEnabled && !_isLocked) {
        setState(() {
          _isLocked = true;
        });
      }
    }
  }

  Future<void> _unlock() async {
    final settingsVm = context.read<SettingsViewModel>();
    if (!settingsVm.isBiometricEnabled) {
      setState(() => _isLocked = false);
      return;
    }
    setState(() => _isAuthenticating = true);
    final canAuth = await settingsVm.securityService.canAuthenticate();
    if (!canAuth) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isLocked = false;
        });
      }
      return;
    }
    final success = await settingsVm.securityService.authenticate();
    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (success) _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    if (settingsVm.isBiometricEnabled && _isLocked) {
      return LockScreen(
        onUnlock: _unlock,
        isAuthenticating: _isAuthenticating,
      );
    }
    return widget.child;
  }
}
