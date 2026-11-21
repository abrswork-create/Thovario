import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Screen displayed when the application is locked via Face ID / Passcode.
class LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;
  final bool isAuthenticating;

  const LockScreen({
    super.key,
    required this.onUnlock,
    this.isAuthenticating = false,
  });

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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.lock_shield_fill,
                        size: 40,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Text(
                    'Thovario Vault',
                    style: AppTypography.headline(primaryColor).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Your private reflections are protected by biometric encryption.',
                    style: AppTypography.body(secondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXl * 1.5),
                  ElevatedButton.icon(
                    onPressed: isAuthenticating ? null : onUnlock,
                    icon: isAuthenticating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(CupertinoIcons.viewfinder, size: 20),
                    label: Text(
                      isAuthenticating ? 'Authenticating...' : 'Unlock with Face ID',
                      style: AppTypography.button(Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXl,
                        vertical: AppTheme.spacingMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
