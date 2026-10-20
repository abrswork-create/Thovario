import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';
import '../../../data/services/export_service.dart';

/// ViewModel managing settings, theme preference, and database maintenance.
class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ThoughtRepository _thoughtRepository;
  final ExportService _exportService;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isExporting = false;
  bool _isDeleting = false;

  SettingsViewModel({
    required this._prefs,
    required this._thoughtRepository,
    ExportService? exportService,
  }) : _exportService = exportService ?? ExportService() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isExporting => _isExporting;
  bool get isDeleting => _isDeleting;

  void _loadThemeMode() {
    final savedMode = _prefs.getString(StorageKeys.themeMode);
    if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.dark; // Default to dark aesthetic
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  /// Exports all thoughts as Markdown and opens the native share sheet.
  Future<bool> exportAllThoughts({Rect? sharePositionOrigin}) async {
    _isExporting = true;
    notifyListeners();
    try {
      final thoughts = await _thoughtRepository.getThoughts(newestFirst: true);
      return await _exportService.exportThoughts(
        thoughts,
        sharePositionOrigin: sharePositionOrigin,
      );
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Deletes all thoughts permanently after confirmation.
  Future<void> deleteAllThoughts() async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _thoughtRepository.deleteAllThoughts();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<List<Thought>> getAllThoughts() async {
    return await _thoughtRepository.getThoughts();
  }
}
