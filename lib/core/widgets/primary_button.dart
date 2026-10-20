import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Standard primary and secondary button for Thovario.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isDestructive;
  final bool isFullWidth;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isDestructive = false,
    this.isFullWidth = true,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor;
    final Color foregroundColor;
    final BorderSide borderSide;

    if (isDestructive) {
      backgroundColor = isDark
          ? AppColors.darkDestructiveSubtle
          : AppColors.lightDestructiveSubtle;
      foregroundColor = isDark
          ? AppColors.darkDestructive
          : AppColors.lightDestructive;
      borderSide = BorderSide(
        color: foregroundColor.withValues(alpha: 0.3),
        width: 1,
      );
    } else if (isSecondary) {
      backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      foregroundColor = isDark
          ? AppColors.darkPrimaryText
          : AppColors.lightPrimaryText;
      borderSide = BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      );
    } else {
      backgroundColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
      foregroundColor = isDark ? AppColors.darkBackground : AppColors.white;
      borderSide = BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: AppTheme.spacingSm),
        ],
        Text(label, style: AppTypography.button(foregroundColor)),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: onPressed == null
            ? backgroundColor.withValues(alpha: 0.4)
            : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: foregroundColor.withValues(alpha: 0.1),
          highlightColor: foregroundColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: content,
          ),
        ),
      ),
    );
  }
}
