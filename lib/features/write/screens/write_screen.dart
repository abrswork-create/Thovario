import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';
import '../view_models/write_view_model.dart';

class WriteScreen extends StatelessWidget {
  final Thought? thoughtToEdit;
  final String? initialPrompt;

  const WriteScreen({super.key, this.thoughtToEdit, this.initialPrompt});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WriteViewModel>(
      create: (context) => WriteViewModel(
        thoughtRepository: context.read<ThoughtRepository>(),
        existingThought: thoughtToEdit,
        initialPrompt: initialPrompt,
      ),
      child: const _WriteScreenContent(),
    );
  }
}

class _WriteScreenContent extends StatefulWidget {
  const _WriteScreenContent();

  @override
  State<_WriteScreenContent> createState() => _WriteScreenContentState();
}

class _WriteScreenContentState extends State<_WriteScreenContent> {
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  bool _isSuccessSaved = false;

  @override
  void dispose() {
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  Future<bool> _handlePop(
    BuildContext context,
    WriteViewModel viewModel,
  ) async {
    if (!viewModel.hasUnsavedChanges || _isSuccessSaved) {
      return true;
    }

    final discard = await ConfirmationDialog.show(
      context: context,
      title: 'Discard draft?',
      message:
          'You have unsaved text in this entry. If you leave now, your changes will be discarded.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Writing',
      isDestructive: true,
    );

    return discard;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WriteViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return PopScope(
      canPop: !viewModel.hasUnsavedChanges || _isSuccessSaved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _isSuccessSaved) return;
        final shouldPop = await _handlePop(context, viewModel);
        if (shouldPop && context.mounted) {
          setState(() {
            _isSuccessSaved = true;
          });
          Navigator.of(context).pop(false);
        }
      },
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping empty space outside inputs
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: TextButton(
              onPressed: () async {
                final shouldPop = await _handlePop(context, viewModel);
                if (shouldPop && context.mounted) {
                  setState(() {
                    _isSuccessSaved = true;
                  });
                  Navigator.of(context).pop(false);
                }
              },
              child: Text(
                'Cancel',
                style: AppTypography.button(secondaryColor),
              ),
            ),
            leadingWidth: 80,
            title: Text(
              viewModel.isEditing ? 'Edit Thought' : 'New Thought',
              style: AppTypography.title(primaryColor),
            ),
            actions: [
              TextButton(
                onPressed: viewModel.canSave && !viewModel.isSaving
                    ? () async {
                        final success = await viewModel.saveThought();
                        if (success && context.mounted) {
                          setState(() {
                            _isSuccessSaved = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thought saved privately.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      }
                    : null,
                child: viewModel.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: AppTypography.button(
                          viewModel.canSave
                              ? accentColor
                              : secondaryColor.withValues(alpha: 0.4),
                        ),
                      ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: Column(
                children: [
                  if (viewModel.errorMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingSm,
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkDestructiveSubtle
                            : AppColors.lightDestructiveSubtle,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTypography.caption(
                          isDark
                              ? AppColors.darkDestructive
                              : AppColors.lightDestructive,
                        ),
                      ),
                    ),
                  ],

                  // Title Field (Optional)
                  TextField(
                    controller: viewModel.titleController,
                    focusNode: _titleFocus,
                    maxLength: AppConstants.maxTitleLength,
                    style: AppTypography.title(
                      primaryColor,
                    ).copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_contentFocus);
                    },
                    decoration: InputDecoration(
                      hintText: 'Title (optional)',
                      hintStyle: AppTypography.title(
                        secondaryColor.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMd,
                      ),
                      filled: false,
                    ),
                  ),

                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 1,
                  ),

                  // Large Multiline Editor
                  Expanded(
                    child: TextField(
                      controller: viewModel.contentController,
                      focusNode: _contentFocus,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      style: AppTypography.body(
                        primaryColor,
                      ).copyWith(fontSize: 17, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Write what you cannot say...',
                        hintStyle: AppTypography.body(
                          secondaryColor.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMd,
                        ),
                        filled: false,
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
