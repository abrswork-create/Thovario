import 'package:flutter/foundation.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';
import '../../../data/services/prompt_service.dart';

/// ViewModel managing state for the Home screen.
class HomeViewModel extends ChangeNotifier {
  final ThoughtRepository _thoughtRepository;
  final PromptService _promptService;

  String _dailyPrompt = '';
  List<Thought> _recentThoughts = [];
  bool _isLoading = false;
  String? _errorMessage;

  HomeViewModel({
    required this._thoughtRepository,
    PromptService? promptService,
  }) : _promptService = promptService ?? PromptService();

  String get dailyPrompt => _dailyPrompt;
  List<Thought> get recentThoughts => _recentThoughts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Deterministic Daily Prompt
      final prompts = await _promptService.loadPrompts();
      _dailyPrompt = _promptService.getDailyPromptForDate(
        DateTime.now(),
        prompts,
      );

      // 2. Recent Thoughts (Top 3)
      final allThoughts = await _thoughtRepository.getThoughts(
        newestFirst: true,
      );
      _recentThoughts = allThoughts.take(3).toList();
    } catch (e) {
      _errorMessage = 'Unable to load thoughts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
