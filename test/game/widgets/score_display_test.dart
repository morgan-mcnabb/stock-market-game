import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/game/widgets/score_display.dart';

void main() {
  Widget buildTestWidget({
    int currentRound = 3,
    int totalRounds = 10,
    int totalScore = 450,
    int currentStreak = 0,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ScoreDisplay(
          currentRound: currentRound,
          totalRounds: totalRounds,
          totalScore: totalScore,
          currentStreak: currentStreak,
        ),
      ),
    );
  }

  group('ScoreDisplay', () {
    testWidgets('shows round progress', (tester) async {
      await tester.pumpWidget(buildTestWidget(currentRound: 3, totalRounds: 10));
      expect(find.text('3/10'), findsOneWidget);
    });

    testWidgets('shows total score', (tester) async {
      await tester.pumpWidget(buildTestWidget(totalScore: 450));
      expect(find.text('450 pts'), findsOneWidget);
    });

    testWidgets('shows zero score', (tester) async {
      await tester.pumpWidget(buildTestWidget(totalScore: 0));
      expect(find.text('0 pts'), findsOneWidget);
    });

    testWidgets('does not show streak label when streak is below threshold',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(currentStreak: 2));

      expect(find.byIcon(Icons.local_fire_department), findsNothing);
      expect(find.textContaining('Hot'), findsNothing);
    });

    testWidgets('shows "Hot!" streak label at streak 3', (tester) async {
      await tester.pumpWidget(buildTestWidget(currentStreak: 3));

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('3 Hot!'), findsOneWidget);
    });

    testWidgets('shows "On Fire!" streak label at streak 5', (tester) async {
      await tester.pumpWidget(buildTestWidget(currentStreak: 5));

      expect(find.text('5 On Fire!'), findsOneWidget);
    });

    testWidgets('shows "Unstoppable!" streak label at streak 7',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(currentStreak: 7));

      expect(find.text('7 Unstoppable!'), findsOneWidget);
    });

    testWidgets('updates round progress correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(currentRound: 1, totalRounds: 10));
      expect(find.text('1/10'), findsOneWidget);

      await tester.pumpWidget(buildTestWidget(currentRound: 10, totalRounds: 10));
      expect(find.text('10/10'), findsOneWidget);
    });
  });
}
