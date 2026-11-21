import 'package:flutter/material.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';

/// ViewModel managing state and persistence for creating and editing thoughts.
class WriteViewModel extends ChangeNotifier {
  final ThoughtRepository _thoughtRepository;
  final Thought? _existingThought;

  late final TextEditingController titleController;
  late final TextEditingController contentController;
  String _selectedMood = 'reflective';

  bool _isSaving = false;
  String? _errorMessage;

  WriteViewModel({
    required this._thoughtRepository,
    Thought? existingThought,
    String? initialPrompt,
  }) : _existingThought = existingThought {
    _selectedMood = existingThought?.mood ?? 'reflective';
    titleController = TextEditingController(text: existingThought?.title ?? '');
    contentController = TextEditingController(
      text: existingThought?.content ?? '',
    );

    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  bool get isEditing => _existingThought != null;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get selectedMood => _selectedMood;

  void setMood(String mood) {
    if (_selectedMood != mood) {
      _selectedMood = mood;
      notifyListeners();
    }
  }

  bool get canSave {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    return title.isNotEmpty || content.isNotEmpty;
  }

  bool get hasUnsavedChanges {
    final currentTitle = titleController.text.trim();
    final currentContent = contentController.text.trim();

    if (_existingThought != null) {
      return currentTitle != _existingThought.title.trim() ||
          currentContent != _existingThought.content.trim() ||
          _selectedMood != _existingThought.mood;
    } else {
      return currentTitle.isNotEmpty ||
          currentContent.isNotEmpty ||
          _selectedMood != 'reflective';
    }
  }

  void _onTextChanged() {
    notifyListeners();
  }

  /// Saves the thought to SQLite. Returns true on success.
  Future<bool> saveThought() async {
    if (!canSave || _isSaving) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final title = titleController.text.trim();
      final content = contentController.text.trim();

      final thought = Thought(
        id:
            _existingThought?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        mood: _selectedMood,
        createdAt: _existingThought?.createdAt ?? now,
        updatedAt: now,
        isFavorite: _existingThought?.isFavorite ?? false,
      );

      await _thoughtRepository.saveThought(thought);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save thought. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
