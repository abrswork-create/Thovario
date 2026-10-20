import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../data/models/thought.dart';
import '../../../data/services/export_service.dart';
import '../../write/screens/write_screen.dart';
import '../view_models/thoughts_view_model.dart';

class ThoughtDetailScreen extends StatefulWidget {
  final Thought thought;

  const ThoughtDetailScreen({super.key, required this.thought});

  @override
  State<ThoughtDetailScreen> createState() => _ThoughtDetailScreenState();
}

class _ThoughtDetailScreenState extends State<ThoughtDetailScreen> {
  late Thought _currentThought;
  final ExportService _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _currentThought = widget.thought;
  }

  Future<void> _toggleFavorite() async {
    final viewModel = context.read<ThoughtsViewModel>();
    await viewModel.toggleFavorite(_currentThought);
    setState(() {
      _currentThought = _currentThought.copyWith(
        isFavorite: !_currentThought.isFavorite,
      );
    });
  }

  Future<void> _deleteThought() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete this thought?',
      message:
          'This action is permanent and cannot be undone. Are you sure you want to remove it?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final viewModel = context.read<ThoughtsViewModel>();
      await viewModel.deleteThought(_currentThought.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _editThought() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => WriteScreen(thoughtToEdit: _currentThought),
      ),
    );

    if (updated == true && mounted) {
      final viewModel = context.read<ThoughtsViewModel>();
      await viewModel.loadThoughts();
      final fresh = viewModel.thoughts.firstWhere(
        (t) => t.id == _currentThought.id,
        orElse: () => _currentThought,
      );
      setState(() {
        _currentThought = fresh;
      });
    }
  }

  Future<void> _shareThought() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Share Entry',
      message:
          'Sharing will pass this thought to the native iOS share sheet, where it will leave the private Thovario environment. Continue?',
      confirmLabel: 'Share',
      cancelLabel: 'Cancel',
    );

    if (confirmed && mounted) {
      await _exportService.shareSingleThought(
        _currentThought,
        sharePositionOrigin: origin,
      );
    }
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
    final hasTitle = _currentThought.title.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentThought.isFavorite
                  ? CupertinoIcons.star_fill
                  : CupertinoIcons.star,
              color: _currentThought.isFavorite
                  ? AppColors.favoriteGold
                  : secondaryColor,
            ),
            tooltip: _currentThought.isFavorite
                ? 'Remove from favorites'
                : 'Mark as favorite',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            tooltip: 'Edit thought',
            onPressed: _editThought,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            tooltip: 'Share thought',
            onPressed: _shareThought,
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.trash,
              color: isDark
                  ? AppColors.darkDestructive
                  : AppColors.lightDestructive,
            ),
            tooltip: 'Delete thought',
            onPressed: _deleteThought,
          ),
          const SizedBox(width: AppTheme.spacingSm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitle) ...[
                Text(
                  _currentThought.title.trim(),
                  style: AppTypography.headline(
                    primaryColor,
                  ).copyWith(fontSize: 26, height: 1.3),
                ),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    DateFormatter.formatDetail(_currentThought.createdAt),
                    style: AppTypography.caption(secondaryColor),
                  ),
                  if (_currentThought.updatedAt.isAfter(
                    _currentThought.createdAt.add(const Duration(minutes: 1)),
                  )) ...[
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      '• edited',
                      style: AppTypography.caption(
                        secondaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                thickness: 1,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              SelectableText(
                _currentThought.content,
                style: AppTypography.body(
                  primaryColor,
                ).copyWith(fontSize: 17, height: 1.6),
              ),
              const SizedBox(height: AppTheme.spacingXl * 2),
            ],
          ),
        ),
      ),
    );
  }
}
