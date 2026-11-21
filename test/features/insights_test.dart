import 'package:flutter_test/flutter_test.dart';
import 'package:thovario/data/models/mood.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/features/insights/view_models/insights_view_model.dart';
import '../test_helpers/fake_thought_repository.dart';

void main() {
  group('InsightsViewModel Tests', () {
    late FakeThoughtRepository repository;
    late InsightsViewModel viewModel;

    setUp(() {
      repository = FakeThoughtRepository();
      viewModel = InsightsViewModel(thoughtRepository: repository);
    });

    test('Initial state is empty with 0 streak and words', () async {
      await viewModel.loadInsights();

      expect(viewModel.totalThoughts, 0);
      expect(viewModel.totalWords, 0);
      expect(viewModel.currentStreak, 0);
      expect(viewModel.dominantMood, isNull);
      expect(viewModel.moodCounts, isEmpty);
    });

    test('Calculates total thoughts, words, and dominant mood correctly', () async {
      final now = DateTime.now();
      await repository.saveThought(
        Thought(
          id: '1',
          title: 'Hello',
          content: 'One two three four five',
          mood: 'grateful',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveThought(
        Thought(
          id: '2',
          title: 'World',
          content: 'Six seven eight',
          mood: 'calm',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveThought(
        Thought(
          id: '3',
          title: 'Another',
          content: 'Nine ten',
          mood: 'grateful',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await viewModel.loadInsights();

      expect(viewModel.totalThoughts, 3);
      expect(viewModel.totalWords, 13); // 'Hello One two three four five' = 6, 'World Six seven eight' = 4, 'Another Nine ten' = 3 -> 13
      expect(viewModel.dominantMood?.key, 'grateful');
      expect(viewModel.moodCounts['grateful'], 2);
      expect(viewModel.moodCounts['calm'], 1);
      expect(viewModel.currentStreak, 1);
    });

    test('Mood model lookup fallback', () {
      expect(Mood.fromKey('calm').key, 'calm');
      expect(Mood.fromKey('nonexistent').key, 'reflective');
      expect(Mood.fromKey(null).key, 'reflective');
    });
  });
}
