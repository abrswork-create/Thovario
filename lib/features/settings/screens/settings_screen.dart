import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../thoughts/view_models/thoughts_view_model.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportAll(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Export all entries?',
      message:
          'This will bundle all your thoughts into a clean Markdown file and present the native iOS share sheet. Exported files can be saved to your device or shared externally.',
      confirmLabel: 'Export',
    );

    if (confirmed && context.mounted) {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      final success = await viewModel.exportAllThoughts(
        sharePositionOrigin: origin,
      );
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No entries to export or export was canceled.'),
          ),
        );
      }
    }
  }

  Future<void> _deleteAll(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final firstConfirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete all entries?',
      message:
          'This will permanently delete every thought saved in Thovario. This action cannot be reversed.',
      confirmLabel: 'Delete All',
      isDestructive: true,
    );

    if (firstConfirm && context.mounted) {
      final finalConfirm = await ConfirmationDialog.show(
        context: context,
        title: 'Final Confirmation',
        message:
            'Are you absolutely sure? All thoughts will be permanently erased.',
        confirmLabel: 'Permanently Erase',
        isDestructive: true,
      );

      if (finalConfirm && context.mounted) {
        await viewModel.deleteAllThoughts();
        if (context.mounted) {
          context.read<ThoughtsViewModel>().loadThoughts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All entries have been permanently erased.'),
            ),
          );
        }
      }
    }
  }

  void _showPrivacyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy & Architecture',
          style: AppTypography.title(primaryColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thovario is built on the principle of private tranquility:',
                style: AppTypography.bodySmall(
                  primaryColor,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                '• 100% Offline: No servers, no accounts, and no cloud synchronization.\n'
                '• Zero Analytics: No tracking, telemetry, or behavioral analysis.\n'
                '• Zero Advertisements: Free forever without commercial interruption.\n'
                '• Local Storage: All entries are stored solely in a local SQLite database on your device.\n'
                '• Your Control: Export or erase your words at any time.',
                style: AppTypography.bodySmall(secondaryColor),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Note on iOS Storage: Data resides within the application sandbox. Standard iOS backups (such as encrypted iCloud or Finder backups) follow your personal device settings.',
                style: AppTypography.caption(secondaryColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: AppTypography.button(
                isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.headline(primaryColor).copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          children: [
            // Appearance Section
            _SectionHeader(title: 'Appearance', secondaryColor: secondaryColor),
            Material(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                side: BorderSide(color: borderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _ThemeRadioTile(
                    title: 'Dark (Default)',
                    subtitle: 'Deep charcoal and calm tones',
                    value: ThemeMode.dark,
                    groupValue: viewModel.themeMode,
                    onChanged: (mode) => viewModel.setThemeMode(mode!),
                  ),
                  Divider(color: borderColor, height: 1),
                  _ThemeRadioTile(
                    title: 'Light',
                    subtitle: 'Tranquil warm paper tone',
                    value: ThemeMode.light,
                    groupValue: viewModel.themeMode,
                    onChanged: (mode) => viewModel.setThemeMode(mode!),
                  ),
                  Divider(color: borderColor, height: 1),
                  _ThemeRadioTile(
                    title: 'System',
                    subtitle: 'Matches device display settings',
                    value: ThemeMode.system,
                    groupValue: viewModel.themeMode,
                    onChanged: (mode) => viewModel.setThemeMode(mode!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Data Management Section
            _SectionHeader(
              title: 'Data & Privacy',
              secondaryColor: secondaryColor,
            ),
            Material(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                side: BorderSide(color: borderColor, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.share_up,
                      color: secondaryColor,
                    ),
                    title: Text(
                      'Export All Thoughts',
                      style: AppTypography.body(primaryColor),
                    ),
                    subtitle: Text(
                      'Save thoughts as readable Markdown',
                      style: AppTypography.caption(secondaryColor),
                    ),
                    trailing: viewModel.isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: secondaryColor,
                          ),
                    onTap: viewModel.isExporting
                        ? null
                        : () => _exportAll(context, viewModel),
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.lock_shield,
                      color: secondaryColor,
                    ),
                    title: Text(
                      'Privacy Architecture',
                      style: AppTypography.body(primaryColor),
                    ),
                    subtitle: Text(
                      'Offline and local data practices',
                      style: AppTypography.caption(secondaryColor),
                    ),
                    trailing: Icon(
                      CupertinoIcons.right_chevron,
                      size: 16,
                      color: secondaryColor,
                    ),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.trash,
                      color: isDark
                          ? AppColors.darkDestructive
                          : AppColors.lightDestructive,
                    ),
                    title: Text(
                      'Delete All Entries',
                      style: AppTypography.body(
                        isDark
                            ? AppColors.darkDestructive
                            : AppColors.lightDestructive,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently erase all stored thoughts',
                      style: AppTypography.caption(secondaryColor),
                    ),
                    trailing: viewModel.isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: isDark
                                ? AppColors.darkDestructive
                                : AppColors.lightDestructive,
                          ),
                    onTap: viewModel.isDeleting
                        ? null
                        : () => _deleteAll(context, viewModel),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // About Application Section
            _SectionHeader(title: 'About', secondaryColor: secondaryColor),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTypography.title(primaryColor),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      AppConstants.appTagline,
                      style: AppTypography.bodySmall(secondaryColor),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Version',
                          style: AppTypography.bodySmall(secondaryColor),
                        ),
                        Text(
                          '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                          style: AppTypography.bodySmall(
                            primaryColor,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl * 1.5),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color secondaryColor;

  const _SectionHeader({required this.title, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption(
          secondaryColor,
        ).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
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
    final isSelected = value == groupValue;

    return ListTile(
      title: Text(title, style: AppTypography.bodyMedium(primaryColor)),
      subtitle: Text(subtitle, style: AppTypography.caption(secondaryColor)),
      trailing: isSelected
          ? Icon(
              CupertinoIcons.checkmark_alt,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            )
          : null,
      onTap: () => onChanged(value),
    );
  }
}
