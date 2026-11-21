import 'package:flutter/foundation.dart';
import '../../../data/models/mood.dart';
import '../../../data/models/thought.dart';
import '../../../data/repositories/thought_repository.dart';

/// ViewModel computing reflection streaks, writing statistics, and mood distribution.
class InsightsViewModel extends ChangeNotifier {
  final ThoughtRepository thoughtRepository;

  bool _isLoading = false;
  int _currentStreak = 0;
  int _totalThoughts = 0;
  int _totalWords = 0;
  int _averageWords = 0;
  Mood? _dominantMood;
  Map<String, int> _moodCounts = {};
  Map<String, double> _moodPercentages = {};
  List<bool> _weeklyActivity = List.filled(7, false); // Mon to Sun

  InsightsViewModel({required this.thoughtRepository});

  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;
  int get totalThoughts => _totalThoughts;
  int get totalWords => _totalWords;
  int get averageWords => _averageWords;
  Mood? get dominantMood => _dominantMood;
  Map<String, int> get moodCounts => _moodCounts;
  Map<String, double> get moodPercentages => _moodPercentages;
  List<bool> get weeklyActivity => _weeklyActivity;

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      final thoughts = await thoughtRepository.getThoughts();
      _calculateStats(thoughts);
    } catch (_) {
      // Fallback gracefully
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStats(List<Thought> thoughts) {
    _totalThoughts = thoughts.length;
    if (thoughts.isEmpty) {
      _currentStreak = 0;
      _totalWords = 0;
      _averageWords = 0;
      _dominantMood = null;
      _moodCounts = {};
      _moodPercentages = {};
      _weeklyActivity = List.filled(7, false);
      return;
    }

    // 1. Total Words & Average Words
    int words = 0;
    for (final t in thoughts) {
      final text = '${t.title} ${t.content}'.trim();
      if (text.isNotEmpty) {
        words += text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      }
    }
    _totalWords = words;
    _averageWords = (_totalWords / _totalThoughts).round();

    // 2. Mood Counts & Percentages
    final counts = <String, int>{};
    for (final t in thoughts) {
      counts[t.mood] = (counts[t.mood] ?? 0) + 1;
    }
    _moodCounts = counts;

    final percentages = <String, double>{};
    String? topMoodKey;
    int maxMoodCount = 0;

    counts.forEach((key, count) {
      percentages[key] = count / _totalThoughts;
      if (count > maxMoodCount) {
        maxMoodCount = count;
        topMoodKey = key;
      }
    });
    _moodPercentages = percentages;
    _dominantMood = topMoodKey != null ? Mood.fromKey(topMoodKey) : null;

    // 3. Consecutive Streak Calculation
    _currentStreak = _computeStreak(thoughts);

    // 4. Past 7 Days Activity (Monday to Sunday of current week)
    _weeklyActivity = _computeWeeklyActivity(thoughts);
  }

  int _computeStreak(List<Thought> thoughts) {
    if (thoughts.isEmpty) return 0;

    // Extract unique calendar dates
    final Set<String> dateStrings = {};
    for (final t in thoughts) {
      final d = t.createdAt;
      dateStrings.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }

    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    final todayStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    int streak = 0;
    if (dateStrings.contains(todayStr)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // Check if user wrote yesterday
      final yesterday = checkDate.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (!dateStrings.contains(yesterdayStr)) {
        return 0;
      }
      checkDate = yesterday;
    }

    while (true) {
      final str = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (dateStrings.contains(str)) {
        if (!dateStrings.contains(todayStr) && streak == 0) {
          streak = 1;
        } else if (streak > 0 && str != todayStr) {
          streak++;
        }
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  List<bool> _computeWeeklyActivity(List<Thought> thoughts) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 (Mon) to 7 (Sun)
    final monday = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: todayWeekday - 1),
    );

    final Set<String> activeDates = {};
    for (final t in thoughts) {
      final d = t.createdAt;
      activeDates.add('${d.year}-${d.month}-${d.day}');
    }

    final List<bool> result = [];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      result.add(activeDates.contains(key));
    }
    return result;
  }
}
