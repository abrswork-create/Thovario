import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/text_helpers.dart';
import '../../../data/models/thought.dart';

/// Reusable card widget for displaying a thought summary in lists.
class ThoughtCard extends StatelessWidget {
  final Thought thought;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ThoughtCard({
    super.key,
    required this.thought,
    required this.onTap,
    required this.onToggleFavorite,
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
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final hasTitle = thought.title.trim().isNotEmpty;
    final preview = TextHelpers.truncate(thought.content, maxLength: 140);
    final dateLabel = DateFormatter.formatCard(thought.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasTitle)
                            Text(
                              thought.title.trim(),
                              style: AppTypography.title(
                                primaryColor,
                              ).copyWith(fontSize: 17),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              dateLabel,
                              style: AppTypography.caption(
                                secondaryColor,
                              ).copyWith(fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        thought.isFavorite
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        size: 20,
                        color: thought.isFavorite
                            ? AppColors.favoriteGold
                            : secondaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      onPressed: onToggleFavorite,
                      tooltip: thought.isFavorite
                          ? 'Remove from favorites'
                          : 'Mark as favorite',
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  preview,
                  style: AppTypography.bodySmall(
                    hasTitle ? secondaryColor : primaryColor,
                  ).copyWith(height: 1.45),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasTitle) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(dateLabel, style: AppTypography.caption(secondaryColor)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
