import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thovario/core/theme/app_theme.dart';
import 'package:thovario/data/repositories/thought_repository.dart';
import 'package:thovario/features/write/screens/write_screen.dart';
import '../test_helpers/fake_thought_repository.dart';

void main() {
  late FakeThoughtRepository repository;

  setUp(() {
    repository = FakeThoughtRepository();
  });

  testWidgets(
    'WriteScreen disables save initially, enables on text input, and saves',
    (tester) async {
      await tester.pumpWidget(
        Provider<ThoughtRepository>.value(
          value: repository,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WriteScreen()),
                    );
                  },
                  child: const Text('Open Write'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open WriteScreen from navigator stack
      await tester.tap(find.text('Open Write'));
      await tester.pumpAndSettle();

      expect(find.text('New Thought'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Save button should be disabled when empty
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(await repository.getThoughts(), isEmpty);

      // Enter thought content
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'Write what you cannot say...',
        ),
        'A quiet truth I kept inside.',
      );
      await tester.pump();

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      final savedThoughts = await repository.getThoughts();
      expect(savedThoughts.length, 1);
      expect(savedThoughts.first.content, 'A quiet truth I kept inside.');
    },
  );
}
