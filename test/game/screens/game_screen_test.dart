import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/data/services/stock_data_service.dart';
import 'package:stock_market_game/game/screens/game_screen.dart';
import 'package:stock_market_game/game/widgets/feedback_overlay.dart';
import 'package:stock_market_game/game/widgets/prediction_buttons.dart';
import 'package:stock_market_game/game/widgets/score_display.dart';
import 'package:stock_market_game/game/widgets/stock_card.dart';

/// Builds a CSV string from a list of [StockRound]s for test injection.
String _buildTestCsv(List<StockRound> stocks) {
  final lines = [
    'ticker,company_name,headline,date,price_before,price_after,direction,percent_change',
    ...stocks.map((s) =>
        '${s.ticker},${s.companyName},${s.headline},${s.date},'
        '${s.priceBefore},${s.priceAfter},${s.correctDirection.name},${s.percentChange}'),
  ];
  return lines.join('\n');
}

/// Creates [count] test [StockRound]s with alternating up/down directions.
List<StockRound> _createTestStocks(int count) {
  return List.generate(
    count,
    (i) => StockRound(
      ticker: 'TST$i',
      companyName: 'Test Corp $i',
      headline: 'Headline $i',
      date: '2025-01-${(i + 1).toString().padLeft(2, '0')}',
      priceBefore: 100.0 + i,
      priceAfter: i.isEven ? 110.0 + i : 90.0 + i,
      correctDirection: i.isEven ? StockDirection.up : StockDirection.down,
      percentChange: i.isEven ? 10.0 : -10.0,
    ),
  );
}

/// Builds a test app with a [GameScreen] and injected stock data.
Widget _buildApp({int stockCount = 3, Map<String, WidgetBuilder>? routes}) {
  final stocks = _createTestStocks(stockCount);
  final csv = _buildTestCsv(stocks);
  return ProviderScope(
    overrides: [
      stockDataServiceProvider.overrideWithValue(
        StockDataService(loadCsv: () async => csv),
      ),
    ],
    child: MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/summary' && routes != null && routes.containsKey('/summary')) {
          return MaterialPageRoute(
            settings: settings,
            builder: routes['/summary']!,
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GameScreen(),
        );
      },
    ),
  );
}

void main() {
  group('GameScreen', () {
    testWidgets('shows loading spinner initially', (tester) async {
      await tester.pumpWidget(_buildApp());
      // Before post-frame callback fires, state is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows stock card and buttons after loading', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(StockCard), findsOneWidget);
      expect(find.byType(PredictionButtons), findsOneWidget);
      expect(find.byType(ScoreDisplay), findsOneWidget);
    });

    testWidgets('displays score display with correct initial values', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Round 1/3, 0 pts (no predictions yet)
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);
    });

    testWidgets('tapping UP shows feedback overlay', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('UP'));
      await tester.pump();

      expect(find.byType(FeedbackOverlay), findsOneWidget);
    });

    testWidgets('tapping DOWN shows feedback overlay', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('DOWN'));
      await tester.pump();

      expect(find.byType(FeedbackOverlay), findsOneWidget);
    });

    testWidgets('buttons are disabled during feedback phase', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('UP'));
      await tester.pump();

      final buttons = tester.widget<PredictionButtons>(
        find.byType(PredictionButtons),
      );
      expect(buttons.enabled, isFalse);
    });

    testWidgets('feedback completes and advances to next stock', (tester) async {
      await tester.pumpWidget(_buildApp(stockCount: 3));
      await tester.pumpAndSettle();

      // Make a prediction on stock 0
      await tester.tap(find.text('UP'));
      await tester.pumpAndSettle(); // Animation completes, nextStock called

      // Should now show stock 1 — score display shows 2/3
      expect(find.text('2/3'), findsOneWidget);
      expect(find.byType(StockCard), findsOneWidget);
      expect(find.byType(FeedbackOverlay), findsNothing);
    });

    testWidgets('navigates to summary after last stock', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          stockCount: 1,
          routes: {
            '/summary': (_) => const Scaffold(body: Text('Summary Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Make prediction on the only stock
      await tester.tap(find.text('UP'));
      await tester.pumpAndSettle();

      expect(find.text('Summary Page'), findsOneWidget);
    });

    testWidgets('shows error state with retry on load failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stockDataServiceProvider.overrideWithValue(
              StockDataService(loadCsv: () async => throw Exception('Network error')),
            ),
          ],
          child: MaterialApp(
            home: const GameScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load stock data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('stock card displays current stock data', (tester) async {
      await tester.pumpWidget(_buildApp(stockCount: 3));
      await tester.pumpAndSettle();

      // Should show one of the test stocks (order is random due to shuffle)
      expect(find.byType(StockCard), findsOneWidget);
      // The stock card displays the ticker, which should be one of TST0, TST1, TST2
      expect(
        find.textContaining('TST'),
        findsWidgets,
      );
    });

    testWidgets('multiple predictions update score display', (tester) async {
      await tester.pumpWidget(_buildApp(stockCount: 3));
      await tester.pumpAndSettle();

      // Make first prediction
      await tester.tap(find.text('UP'));
      await tester.pumpAndSettle();

      // Now on stock 2 — check the round counter updated
      expect(find.text('2/3'), findsOneWidget);

      // Make second prediction
      await tester.tap(find.text('UP'));
      await tester.pumpAndSettle();

      // Now on stock 3
      expect(find.text('3/3'), findsOneWidget);
    });
  });
}
