import 'package:flutter_test/flutter_test.dart';
import 'package:thovario/data/services/prompt_service.dart';

void main() {
  group('PromptService Determinism Tests', () {
    late PromptService service;
    final testPrompts = [
      'Prompt Alpha',
      'Prompt Beta',
      'Prompt Gamma',
      'Prompt Delta',
      'Prompt Epsilon',
    ];

    setUp(() {
      service = PromptService();
    });

    test(
      'Returns identical daily prompt regardless of time of day on same date',
      () {
        final morning = DateTime(2026, 10, 19, 7, 0, 0);
        final noon = DateTime(2026, 10, 19, 12, 30, 0);
        final night = DateTime(2026, 10, 19, 23, 59, 59);

        final pMorning = service.getDailyPromptForDate(morning, testPrompts);
        final pNoon = service.getDailyPromptForDate(noon, testPrompts);
        final pNight = service.getDailyPromptForDate(night, testPrompts);

        expect(pMorning, equals(pNoon));
        expect(pNoon, equals(pNight));
      },
    );

    test('Yields different prompt on consecutive days', () {
      final day1 = DateTime(2026, 10, 19);
      final day2 = DateTime(2026, 10, 20);

      final prompt1 = service.getDailyPromptForDate(day1, testPrompts);
      final prompt2 = service.getDailyPromptForDate(day2, testPrompts);

      expect(prompt1, isNotEmpty);
      expect(prompt2, isNotEmpty);
      // Consecutively seeded indices will differ given 5 items
      expect(prompt1 != prompt2, isTrue);
    });

    test('Handles empty prompt list with graceful fallback', () {
      final prompt = service.getDailyPromptForDate(DateTime(2026, 10, 19), []);
      expect(prompt, isNotEmpty);
    });
  });
}
