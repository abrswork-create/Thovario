import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../navigation/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<({String title, String description, IconData icon})>
  _pages = const [
    (
      title: "Some things don't need to be sent.",
      description: "A quiet place for everything you want to say.",
      icon: CupertinoIcons.wind,
    ),
    (
      title: "Your words belong to you.",
      description:
          "Write privately, save your thoughts, and return whenever you're ready.",
      icon: CupertinoIcons.lock_shield,
    ),
    (
      title: "No pressure. No audience.",
      description: "Just you and your thoughts.",
      icon: CupertinoIcons.moon_stars,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.hasCompletedOnboarding, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => const MainNavigation(),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with App Branding and Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConstants.appName,
                    style: AppTypography.title(
                      accentColor,
                    ).copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w700),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                      ),
                      child: Text(
                        'Skip',
                        style: AppTypography.button(secondaryColor),
                      ),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          child: Icon(item.icon, size: 38, color: accentColor),
                        ),
                        const SizedBox(height: AppTheme.spacingXl * 1.5),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headline(
                            primaryColor,
                          ).copyWith(fontSize: 26, height: 1.3),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(secondaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator dots and Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingXl,
                0,
                AppTheme.spacingXl,
                AppTheme.spacingLg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? accentColor
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  PrimaryButton(
                    label: isLastPage ? 'Get Started' : 'Continue',
                    onPressed: _nextPage,
                    icon: isLastPage ? CupertinoIcons.arrow_right : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
