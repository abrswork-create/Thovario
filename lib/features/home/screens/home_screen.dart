import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/thought.dart';
import '../../thoughts/screens/thought_detail_screen.dart';
import '../../thoughts/view_models/thoughts_view_model.dart';
import '../../thoughts/widgets/thought_card.dart';
import '../../write/screens/write_screen.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.onSelectTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    context.read<HomeViewModel>().loadHomeData();
    context.read<ThoughtsViewModel>().loadThoughts();
  }

  void _navigateToWrite({String? prompt}) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder: (context) => WriteScreen(initialPrompt: prompt),
          ),
        )
        .then((saved) {
          if (saved == true && mounted) {
            _refresh();
          }
        });
  }

  void _openDetail(Thought thought) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ThoughtDetailScreen(thought: thought),
          ),
        )
        .then((_) {
          if (mounted) {
            _refresh();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final thoughtsVm = context.watch<ThoughtsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTypography.title(accentColor).copyWith(
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormatter.formatHeader(DateTime.now()),
                      style: AppTypography.caption(secondaryColor),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Emotional Headline and Supporting Statement
                Text(
                  'Let it out.',
                  style: AppTypography.display(
                    primaryColor,
                  ).copyWith(fontSize: 34, height: 1.15),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Whatever is on your mind, it can stay here.',
                  style: AppTypography.body(secondaryColor),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Primary "Write something" CTA
                PrimaryButton(
                  label: 'Write something',
                  icon: CupertinoIcons.pencil_ellipsis_rectangle,
                  onPressed: () => _navigateToWrite(),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Daily Reflection Prompt Card
                if (homeVm.dailyPrompt.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.sparkles,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              'DAILY PROMPT',
                              style: AppTypography.caption(accentColor)
                                  .copyWith(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          '"${homeVm.dailyPrompt}"',
                          style: AppTypography.bodyMedium(
                            primaryColor,
                          ).copyWith(fontStyle: FontStyle.italic, height: 1.45),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: Icon(
                              CupertinoIcons.arrow_right,
                              size: 14,
                              color: accentColor,
                            ),
                            label: Text(
                              'Answer prompt',
                              style: AppTypography.caption(
                                accentColor,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            onPressed: () =>
                                _navigateToWrite(prompt: homeVm.dailyPrompt),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],

                // Recent Entries Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Thoughts',
                      style: AppTypography.title(
                        primaryColor,
                      ).copyWith(fontSize: 18),
                    ),
                    if (homeVm.recentThoughts.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          if (widget.onSelectTab != null) {
                            widget.onSelectTab!(1); // Go to My Thoughts tab
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'View all',
                          style: AppTypography.button(
                            accentColor,
                          ).copyWith(fontSize: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Recent entries list or first-use quiet empty state
                if (homeVm.recentThoughts.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingXl,
                      horizontal: AppTheme.spacingLg,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.moon,
                          size: 28,
                          color: secondaryColor,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'No entries yet',
                          style: AppTypography.title(
                            primaryColor,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          'Write a fleeting feeling, a memory, or an unsent note.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(secondaryColor),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: homeVm.recentThoughts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final thought = homeVm.recentThoughts[index];
                      return ThoughtCard(
                        thought: thought,
                        onTap: () => _openDetail(thought),
                        onToggleFavorite: () async {
                          await thoughtsVm.toggleFavorite(thought);
                          _refresh();
                        },
                      );
                    },
                  ),
                ],

                const SizedBox(height: AppTheme.spacingXl * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
