import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thovario/core/theme/app_theme.dart';
import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/repositories/thought_repository.dart';
import 'package:thovario/data/services/prompt_service.dart';
import 'package:thovario/features/home/screens/home_screen.dart';
import 'package:thovario/features/home/view_models/home_view_model.dart';
import 'package:thovario/features/thoughts/view_models/thoughts_view_model.dart';
import '../test_helpers/fake_thought_repository.dart';

class TestPromptService extends PromptService {
  @override
  Future<List<String>> loadPrompts() async {
    return [
      'What is something you never said because you thought it was too late?',
    ];
  }
}

void main() {
  late FakeThoughtRepository repository;

  setUp(() {
    repository = FakeThoughtRepository([
      Thought(
        id: '1',
        title: 'Reflections',
        content: 'Gentle moments in the morning.',
        createdAt: DateTime(2026, 10, 19, 9, 0),
        updatedAt: DateTime(2026, 10, 19, 9, 0),
      ),
    ]);
  });

  testWidgets(
    'Renders HomeScreen with official branding, headline, and daily prompt',
    (tester) async {
      final homeViewModel = HomeViewModel(
        thoughtRepository: repository,
        promptService: TestPromptService(),
      );
      final thoughtsViewModel = ThoughtsViewModel(
        thoughtRepository: repository,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ThoughtRepository>.value(value: repository),
            ChangeNotifierProvider<HomeViewModel>.value(value: homeViewModel),
            ChangeNotifierProvider<ThoughtsViewModel>.value(
              value: thoughtsViewModel,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify official branding & headlines
      expect(find.text('Thovario'), findsOneWidget);
      expect(find.text('Let it out.'), findsOneWidget);
      expect(
        find.text('Whatever is on your mind, it can stay here.'),
        findsOneWidget,
      );
      expect(find.text('Write something'), findsOneWidget);
      expect(find.text('Recent Thoughts'), findsOneWidget);
      expect(find.text('DAILY PROMPT'), findsOneWidget);
      expect(find.text('Reflections'), findsOneWidget);
    },
  );
}
