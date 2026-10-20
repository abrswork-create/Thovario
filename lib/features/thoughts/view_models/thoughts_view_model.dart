import 'package:flutter/foundation.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';

/// ViewModel managing thoughts list, searching, sorting, and favorites.
class ThoughtsViewModel extends ChangeNotifier {
  final ThoughtRepository _thoughtRepository;

  List<Thought> _thoughts = [];
  List<Thought> _favoriteThoughts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _newestFirst = true;
  String? _errorMessage;

  ThoughtsViewModel({required this._thoughtRepository});

  List<Thought> get thoughts => _thoughts;
  List<Thought> get favoriteThoughts => _favoriteThoughts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get newestFirst => _newestFirst;
  String? get errorMessage => _errorMessage;

  Future<void> loadThoughts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_searchQuery.trim().isEmpty) {
        _thoughts = await _thoughtRepository.getThoughts(
          newestFirst: _newestFirst,
        );
      } else {
        _thoughts = await _thoughtRepository.searchThoughts(
          _searchQuery,
          newestFirst: _newestFirst,
        );
      }
      _favoriteThoughts = await _thoughtRepository.getFavorites(
        newestFirst: _newestFirst,
      );
    } catch (e) {
      _errorMessage = 'Could not load thoughts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadThoughts();
    }
  }

  void toggleSortOrder() {
    _newestFirst = !_newestFirst;
    loadThoughts();
  }

  Future<void> toggleFavorite(Thought thought) async {
    await _thoughtRepository.toggleFavorite(thought.id, thought.isFavorite);
    await loadThoughts();
  }

  Future<void> deleteThought(String id) async {
    await _thoughtRepository.deleteThought(id);
    await loadThoughts();
  }
}
