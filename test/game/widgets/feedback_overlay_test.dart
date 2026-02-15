import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/game/widgets/feedback_overlay.dart';

void main() {
  Widget buildTestWidget({
    required bool isCorrect,
    int pointsEarned = 100,
    double priceBefore = 150.00,
    double priceAfter = 165.00,
    required VoidCallback onComplete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FeedbackOverlay(
            isCorrect: isCorrect,
            pointsEarned: pointsEarned,
            priceBefore: priceBefore,
            priceAfter: priceAfter,
            onComplete: onComplete,
          ),
        ),
      ),
    );
  }

  group('FeedbackOverlay', () {
    testWidgets('shows "Correct!" text when isCorrect is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(isCorrect: true, onComplete: () {}),
      );
      await tester.pump();

      expect(find.text('Correct!'), findsOneWidget);
    });

    testWidgets('shows "Wrong!" text when isCorrect is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(isCorrect: false, onComplete: () {}),
      );
      await tester.pump();

      expect(find.text('Wrong!'), findsOneWidget);
    });

    testWidgets('shows points earned when correct', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCorrect: true,
          pointsEarned: 150,
          onComplete: () {},
        ),
      );
      await tester.pump();

      expect(find.text('+150 pts'), findsOneWidget);
    });

    testWidgets('does not show points when wrong', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCorrect: false,
          pointsEarned: 0,
          onComplete: () {},
        ),
      );
      await tester.pump();

      // The "+X pts" row should be absent; only the price reveal line renders
      expect(find.text('+0 pts'), findsNothing);
      expect(find.text('+100 pts'), findsNothing);
    });

    testWidgets('shows price reveal', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCorrect: true,
          priceBefore: 150.00,
          priceAfter: 165.50,
          onComplete: () {},
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$150.00'), findsOneWidget);
      expect(find.textContaining('\$165.50'), findsOneWidget);
    });

    testWidgets('shows check icon when correct', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(isCorrect: true, onComplete: () {}),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('shows cancel icon when wrong', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(isCorrect: false, onComplete: () {}),
      );
      await tester.pump();

      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('calls onComplete after animation finishes', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        buildTestWidget(isCorrect: true, onComplete: () => completed = true),
      );

      // Animation hasn't finished yet
      await tester.pump(const Duration(milliseconds: 500));
      expect(completed, isFalse);

      // Let animation complete (1500ms total)
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });
  });
}
