import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/game_result.dart';
import 'package:stock_market_game/data/models/prediction.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/data/services/stock_data_service.dart';
import 'package:stock_market_game/game/logic/game_state.dart';
import 'package:stock_market_game/game/screens/score_summary_screen.dart';

const _stockUp = StockRound(
  ticker: 'AAPL',
  companyName: 'Apple Inc.',
  headline: 'Apple soars',
  date: '2024-01-15',
  priceBefore: 150.0,
  priceAfter: 165.0,
  correctDirection: StockDirection.up,
  percentChange: 10.0,
);

const _stockDown = StockRound(
  ticker: 'GOOG',
  companyName: 'Alphabet Inc.',
  headline: 'Google drops',
  date: '2024-02-20',
  priceBefore: 140.0,
  priceAfter: 126.0,
  correctDirection: StockDirection.down,
  percentChange: -10.0,
);

GameResult _buildResult({
  List<Prediction>? predictions,
  int? totalScore,
  int? bestStreak,
  int? correctCount,
  int? totalRounds,
}) {
  final preds = predictions ??
      [
        const Prediction(
          stockRound: _stockUp,
          userPick: StockDirection.up,
          isCorrect: true,
          pointsEarned: 100,
          streakAtTime: 1,
        ),
        const Prediction(
          stockRound: _stockDown,
          userPick: StockDirection.up,
          isCorrect: false,
          pointsEarned: 0,
          streakAtTime: 0,
        ),
      ];
  return GameResult(
    predictions: preds,
    totalScore: totalScore ?? 100,
    bestStreak: bestStreak ?? 1,
    correctCount: correctCount ?? 1,
    totalRounds: totalRounds ?? 2,
    playedAt: DateTime(2024, 1, 15),
  );
}

void main() {
  Widget buildSubject({GameResult? result}) {
    final gameResult = result ?? _buildResult();
    return ProviderScope(
      overrides: [
        gameStateProvider.overrideWith(() => _TestGameStateNotifier(
              GameState(
                phase: GamePhase.roundComplete,
                finalResult: gameResult,
                predictions: gameResult.predictions,
                totalScore: gameResult.totalScore,
                currentStreak: 0,
                roundStocks: gameResult.predictions
                    .map((p) => p.stockRound)
                    .toList(),
                currentStockIndex: gameResult.totalRounds - 1,
              ),
            )),
        stockDataServiceProvider.overrideWithValue(
          StockDataService(loadCsv: () async => ''),
        ),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ScoreSummaryScreen(),
            );
          }
          if (settings.name == '/summary') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ScoreSummaryScreen(),
            );
          }
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ScoreSummaryScreen(),
          );
        },
      ),
    );
  }

  group('ScoreSummaryScreen', () {
    testWidgets('displays total score', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('100 pts'), findsOneWidget);
    });

    testWidgets('displays correct count and total', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
    });

    testWidgets('displays accuracy percentage', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
    });

    testWidgets('displays best streak', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);
    });

    testWidgets('displays grade badge', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 50% accuracy -> grade F
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('displays grade A for perfect score', (tester) async {
      final perfectResult = GameResult(
        predictions: const [
          Prediction(
            stockRound: _stockUp,
            userPick: StockDirection.up,
            isCorrect: true,
            pointsEarned: 100,
            streakAtTime: 1,
          ),
          Prediction(
            stockRound: _stockDown,
            userPick: StockDirection.down,
            isCorrect: true,
            pointsEarned: 150,
            streakAtTime: 2,
          ),
        ],
        totalScore: 250,
        bestStreak: 2,
        correctCount: 2,
        totalRounds: 2,
        playedAt: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(buildSubject(result: perfectResult));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('250 pts'), findsOneWidget);
    });

    testWidgets('displays prediction history rows', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Two predictions -> two tickers in the list
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('GOOG'), findsOneWidget);
    });

    testWidgets('shows correct/wrong icons in prediction history', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // One correct (check_circle), one wrong (cancel)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('shows points earned per prediction', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('+100'), findsOneWidget);
      expect(find.text('+0'), findsOneWidget);
    });

    testWidgets('shows pick direction labels', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // First prediction picked UP, second picked UP (both wrong/right)
      expect(find.text('UP'), findsAtLeastNWidgets(2));
    });

    testWidgets('Play Again button is displayed', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Play Again'), findsOneWidget);
    });

    testWidgets('displays Round Complete in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Round Complete'), findsOneWidget);
    });

    testWidgets('displays no results message when finalResult is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stockDataServiceProvider.overrideWithValue(
              StockDataService(loadCsv: () async => ''),
            ),
          ],
          child: const MaterialApp(
            home: ScoreSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No results available'), findsOneWidget);
    });

    testWidgets('score animates from 0 to total', (tester) async {
      await tester.pumpWidget(buildSubject());

      // At the start of animation, score should be near 0
      await tester.pump(const Duration(milliseconds: 50));
      // Partway through — just ensure no crash and widget exists
      expect(find.textContaining('pts'), findsOneWidget);

      // After animation completes
      await tester.pumpAndSettle();
      expect(find.text('100 pts'), findsOneWidget);
    });

    testWidgets('streak badge with fire icon shown for streak >= 3', (tester) async {
      final result = _buildResult(bestStreak: 5);

      await tester.pumpWidget(buildSubject(result: result));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('no fire icon when best streak < 3', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Default result has bestStreak=1
      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });
  });
}

/// A test-only [GameStateNotifier] that starts with a pre-set state.
class _TestGameStateNotifier extends GameStateNotifier {
  final GameState _initial;
  _TestGameStateNotifier(this._initial);

  @override
  GameState build() => _initial;
}
