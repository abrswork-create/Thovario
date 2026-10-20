import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/thought.dart';
import '../../thoughts/screens/thought_detail_screen.dart';
import '../../thoughts/view_models/thoughts_view_model.dart';
import '../../thoughts/widgets/thought_card.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onNavigateToThoughts;

  const FavoritesScreen({super.key, this.onNavigateToThoughts});

  void _openDetail(BuildContext context, Thought thought) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThoughtDetailScreen(thought: thought),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThoughtsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTypography.headline(primaryColor).copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (viewModel.isLoading && viewModel.favoriteThoughts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.favoriteThoughts.isEmpty) {
              return EmptyState(
                icon: CupertinoIcons.star,
                title: 'No favorites yet',
                message:
                    'Mark any thought with a star to keep it easily accessible in this sanctuary.',
                actionLabel: onNavigateToThoughts != null
                    ? 'View all thoughts'
                    : null,
                onActionPressed: onNavigateToThoughts,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
              itemCount: viewModel.favoriteThoughts.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppTheme.spacingMd),
              itemBuilder: (context, index) {
                final thought = viewModel.favoriteThoughts[index];
                return ThoughtCard(
                  thought: thought,
                  onTap: () => _openDetail(context, thought),
                  onToggleFavorite: () => viewModel.toggleFavorite(thought),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
