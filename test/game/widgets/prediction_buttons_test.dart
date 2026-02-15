import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/game/widgets/prediction_buttons.dart';

void main() {
  Widget buildTestWidget({
    required ValueChanged<StockDirection> onPrediction,
    bool enabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PredictionButtons(
          onPrediction: onPrediction,
          enabled: enabled,
        ),
      ),
    );
  }

  group('PredictionButtons', () {
    testWidgets('displays UP and DOWN labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(onPrediction: (_) {}));

      expect(find.text('UP'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);
    });

    testWidgets('displays trending up and down icons', (tester) async {
      await tester.pumpWidget(buildTestWidget(onPrediction: (_) {}));

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('tapping UP fires onPrediction with StockDirection.up',
        (tester) async {
      StockDirection? result;
      await tester.pumpWidget(
        buildTestWidget(onPrediction: (d) => result = d),
      );

      await tester.tap(find.text('UP'));
      expect(result, StockDirection.up);
    });

    testWidgets('tapping DOWN fires onPrediction with StockDirection.down',
        (tester) async {
      StockDirection? result;
      await tester.pumpWidget(
        buildTestWidget(onPrediction: (d) => result = d),
      );

      await tester.tap(find.text('DOWN'));
      expect(result, StockDirection.down);
    });

    testWidgets('buttons do not fire callback when disabled', (tester) async {
      StockDirection? result;
      await tester.pumpWidget(
        buildTestWidget(onPrediction: (d) => result = d, enabled: false),
      );

      await tester.tap(find.text('UP'));
      await tester.tap(find.text('DOWN'));
      expect(result, isNull);
    });

    testWidgets('buttons are visually dimmed when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPrediction: (_) {}, enabled: false),
      );
      await tester.pumpAndSettle();

      // Both buttons should have AnimatedOpacity with 0.4
      final opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.opacity, 0.4);
      }
    });

    testWidgets('buttons are fully opaque when enabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPrediction: (_) {}, enabled: true),
      );
      await tester.pumpAndSettle();

      final opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.opacity, 1.0);
      }
    });
  });
}
