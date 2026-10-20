import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thovario/app.dart';
import 'package:thovario/core/constants/storage_keys.dart';
import '../test_helpers/fake_thought_repository.dart';

void main() {
  late FakeThoughtRepository repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = FakeThoughtRepository();
  });

  testWidgets('Renders onboarding screen 1 and navigates to subsequent screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      ThovarioApp(
        prefs: prefs,
        hasCompletedOnboarding: false,
        thoughtRepository: repository,
      ),
    );

    await tester.pumpAndSettle();

    // Verify Screen 1 content per specification
    expect(find.text('Thovario'), findsOneWidget);
    expect(find.text("Some things don't need to be sent."), findsOneWidget);
    expect(
      find.text('A quiet place for everything you want to say.'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Continue to advance to Screen 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Your words belong to you.'), findsOneWidget);
    expect(
      find.text(
        'Write privately, save your thoughts, and return whenever you\'re ready.',
      ),
      findsOneWidget,
    );

    // Tap Continue to advance to Screen 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('No pressure. No audience.'), findsOneWidget);
    expect(find.text('Just you and your thoughts.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started to finish onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(prefs.getBool(StorageKeys.hasCompletedOnboarding), isTrue);
  });
}
