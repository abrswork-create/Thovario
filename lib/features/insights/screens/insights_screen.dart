import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/mood.dart';
import '../view_models/insights_view_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsViewModel>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsViewModel>();
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
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: AppTypography.headline(primaryColor).copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context.read<InsightsViewModel>().loadInsights(),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            children: [
              // Hero Streak Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E1838),
                            const Color(0xFF131122),
                          ]
                        : [
                            const Color(0xFFF3EDFF),
                            const Color(0xFFE9E0FF),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.flame_fill,
                          color: const Color(0xFFF97316),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${viewModel.currentStreak} Day ${viewModel.currentStreak == 1 ? 'Streak' : 'Streak'}',
                            style: AppTypography.headline(primaryColor).copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            viewModel.currentStreak > 0
                                ? 'Consistency creates peace. Keep writing.'
                                : 'Record a thought today to begin your streak.',
                            style: AppTypography.caption(secondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Weekly Activity Tracker
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THIS WEEK\'S RHYTHM',
                      style: AppTypography.caption(secondaryColor).copyWith(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WeekDayDot(label: 'M', active: viewModel.weeklyActivity[0], accentColor: accentColor),
                        _WeekDayDot(label: 'T', active: viewModel.weeklyActivity[1], accentColor: accentColor),
                        _WeekDayDot(label: 'W', active: viewModel.weeklyActivity[2], accentColor: accentColor),
                        _WeekDayDot(label: 'T', active: viewModel.weeklyActivity[3], accentColor: accentColor),
                        _WeekDayDot(label: 'F', active: viewModel.weeklyActivity[4], accentColor: accentColor),
                        _WeekDayDot(label: 'S', active: viewModel.weeklyActivity[5], accentColor: accentColor),
                        _WeekDayDot(label: 'S', active: viewModel.weeklyActivity[6], accentColor: accentColor),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // 3-Stat Metric Grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Reflections',
                      value: '${viewModel.totalThoughts}',
                      icon: CupertinoIcons.doc_text_fill,
                      iconColor: const Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: 'Total Words',
                      value: '${viewModel.totalWords}',
                      icon: CupertinoIcons.pencil,
                      iconColor: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: 'Avg Words',
                      value: '${viewModel.averageWords}',
                      icon: CupertinoIcons.chart_bar_fill,
                      iconColor: const Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Emotional Horizon (Mood Distribution)
              Text(
                'EMOTIONAL HORIZON',
                style: AppTypography.caption(secondaryColor).copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: viewModel.totalThoughts == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                        child: Center(
                          child: Text(
                            'No moods recorded yet. Write your first thought to see your emotional horizon.',
                            style: AppTypography.caption(secondaryColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        children: Mood.all.map((mood) {
                          final count = viewModel.moodCounts[mood.key] ?? 0;
                          final pct = viewModel.moodPercentages[mood.key] ?? 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(mood.icon, size: 14, color: mood.color),
                                    const SizedBox(width: 8),
                                    Text(
                                      mood.label,
                                      style: AppTypography.bodySmall(primaryColor).copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$count (${(pct * 100).toStringAsFixed(0)}%)',
                                      style: AppTypography.caption(secondaryColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                    valueColor: AlwaysStoppedAnimation<Color>(mood.color),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: AppTheme.spacingXl * 1.5),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekDayDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color accentColor;

  const _WeekDayDot({
    required this.label,
    required this.active,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: active
                ? const Icon(CupertinoIcons.checkmark, size: 16, color: Colors.white)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: secondaryColor,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.title(primaryColor).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption(secondaryColor).copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
