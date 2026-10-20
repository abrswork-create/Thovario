import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/thought.dart';
import '../../write/screens/write_screen.dart';
import '../view_models/thoughts_view_model.dart';
import '../widgets/thought_card.dart';
import 'thought_detail_screen.dart';

class ThoughtsScreen extends StatefulWidget {
  const ThoughtsScreen({super.key});

  @override
  State<ThoughtsScreen> createState() => _ThoughtsScreenState();
}

class _ThoughtsScreenState extends State<ThoughtsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThoughtsViewModel>().loadThoughts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Thought thought) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThoughtDetailScreen(thought: thought),
      ),
    );
  }

  void _createNewThought() {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(builder: (context) => const WriteScreen()),
        )
        .then((saved) {
          if (saved == true && mounted) {
            context.read<ThoughtsViewModel>().loadThoughts();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThoughtsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Thoughts',
          style: AppTypography.headline(primaryColor).copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.newestFirst
                  ? CupertinoIcons.arrow_down
                  : CupertinoIcons.arrow_up,
              size: 20,
            ),
            tooltip: viewModel.newestFirst
                ? 'Sorting: Newest first'
                : 'Sorting: Oldest first',
            onPressed: () => viewModel.toggleSortOrder(),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_pencil, size: 22),
            tooltip: 'Write new thought',
            onPressed: _createNewThought,
          ),
          const SizedBox(width: AppTheme.spacingSm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingSm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => viewModel.setSearchQuery(val),
                style: AppTypography.bodySmall(primaryColor),
                decoration: InputDecoration(
                  hintText: 'Search thoughts...',
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: secondaryColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 18,
                          ),
                          color: secondaryColor,
                          onPressed: () {
                            _searchController.clear();
                            viewModel.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModel.isLoading && viewModel.thoughts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.errorMessage != null &&
                      viewModel.thoughts.isEmpty) {
                    return Center(
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTypography.bodySmall(
                          isDark
                              ? AppColors.darkDestructive
                              : AppColors.lightDestructive,
                        ),
                      ),
                    );
                  }

                  // No thoughts in database at all
                  if (viewModel.thoughts.isEmpty &&
                      viewModel.searchQuery.isEmpty) {
                    return EmptyState(
                      icon: CupertinoIcons.doc_text,
                      title: 'Quiet here',
                      message:
                          'You have not written any thoughts yet. Your words can stay here whenever you are ready.',
                      actionLabel: 'Write a thought',
                      onActionPressed: _createNewThought,
                    );
                  }

                  // Search returned no results
                  if (viewModel.thoughts.isEmpty &&
                      viewModel.searchQuery.isNotEmpty) {
                    return EmptyState(
                      icon: CupertinoIcons.search,
                      title: 'No thoughts found',
                      message:
                          'No saved thoughts match "${viewModel.searchQuery}". Try a different word or clear search.',
                      actionLabel: 'Clear Search',
                      onActionPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingMd,
                    ),
                    itemCount: viewModel.thoughts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final thought = viewModel.thoughts[index];
                      return Dismissible(
                        key: ValueKey(thought.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(
                            right: AppTheme.spacingLg,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkDestructiveSubtle
                                : AppColors.lightDestructiveSubtle,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.trash,
                            color: isDark
                                ? AppColors.darkDestructive
                                : AppColors.lightDestructive,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await ConfirmationDialog.show(
                            context: context,
                            title: 'Delete this thought?',
                            message: 'This will permanently remove this entry.',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                          );
                        },
                        onDismissed: (direction) {
                          viewModel.deleteThought(thought.id);
                        },
                        child: ThoughtCard(
                          thought: thought,
                          onTap: () => _openDetail(thought),
                          onToggleFavorite: () =>
                              viewModel.toggleFavorite(thought),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
