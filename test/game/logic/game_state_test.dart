import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/core/constants/game_constants.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/data/services/stock_data_service.dart';
import 'package:stock_market_game/game/logic/game_state.dart';

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

/// Creates a [ProviderContainer] with a [StockDataService] loaded from test stocks.
ProviderContainer _createContainer({int stockCount = 10}) {
  final stocks = _createTestStocks(stockCount);
  final csv = _buildTestCsv(stocks);
  return ProviderContainer(
    overrides: [
      stockDataServiceProvider.overrideWithValue(
        StockDataService(loadCsv: () async => csv),
      ),
    ],
  );
}

void main() {
  group('GameState', () {
    test('default constructor produces loading state', () {
      const state = GameState();
      expect(state.phase, GamePhase.loading);
      expect(state.roundStocks, isEmpty);
      expect(state.currentStockIndex, 0);
      expect(state.predictions, isEmpty);
      expect(state.currentStreak, 0);
      expect(state.totalScore, 0);
      expect(state.finalResult, isNull);
    });

    test('currentStock returns null when no stocks loaded', () {
      const state = GameState();
      expect(state.currentStock, isNull);
    });

    test('currentStock returns the stock at currentStockIndex', () {
      final stocks = _createTestStocks(3);
      final state = GameState(
        phase: GamePhase.showingStock,
        roundStocks: stocks,
        currentStockIndex: 1,
      );
      expect(state.currentStock, stocks[1]);
    });

    test('copyWith preserves unchanged fields', () {
      final stocks = _createTestStocks(3);
      final original = GameState(
        phase: GamePhase.showingStock,
        roundStocks: stocks,
        currentStockIndex: 1,
        totalScore: 200,
      );
      final copied = original.copyWith(phase: GamePhase.showingResult);
      expect(copied.phase, GamePhase.showingResult);
      expect(copied.roundStocks, stocks);
      expect(copied.currentStockIndex, 1);
      expect(copied.totalScore, 200);
    });
  });

  group('GameStateNotifier', () {
    test('starts in loading phase', () {
      final container = _createContainer();
      addTearDown(container.dispose);

      final state = container.read(gameStateProvider);
      expect(state.phase, GamePhase.loading);
    });

    test('startNewRound transitions to showingStock with stocks', () async {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);

      await notifier.startNewRound();

      final state = container.read(gameStateProvider);
      expect(state.phase, GamePhase.showingStock);
      expect(state.roundStocks.length, GameConstants.roundSize);
      expect(state.currentStockIndex, 0);
      expect(state.currentStock, isNotNull);
      expect(state.predictions, isEmpty);
      expect(state.currentStreak, 0);
      expect(state.totalScore, 0);
    });

    group('makePrediction', () {
      test('correct answer transitions to showingResult', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        final stock = container.read(gameStateProvider).currentStock!;
        notifier.makePrediction(stock.correctDirection);

        final state = container.read(gameStateProvider);
        expect(state.phase, GamePhase.showingResult);
      });

      test('correct answer increments streak and score', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        final stock = container.read(gameStateProvider).currentStock!;
        notifier.makePrediction(stock.correctDirection);

        final state = container.read(gameStateProvider);
        expect(state.currentStreak, 1);
        expect(state.totalScore, 100); // streak 1 = 1x = 100
        expect(state.predictions.length, 1);
        expect(state.predictions.first.isCorrect, isTrue);
        expect(state.predictions.first.pointsEarned, 100);
        expect(state.predictions.first.streakAtTime, 1);
      });

      test('wrong answer resets streak and earns zero points', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        final stock = container.read(gameStateProvider).currentStock!;
        final wrongPick = stock.correctDirection == StockDirection.up
            ? StockDirection.down
            : StockDirection.up;
        notifier.makePrediction(wrongPick);

        final state = container.read(gameStateProvider);
        expect(state.currentStreak, 0);
        expect(state.totalScore, 0);
        expect(state.predictions.first.isCorrect, isFalse);
        expect(state.predictions.first.pointsEarned, 0);
        expect(state.predictions.first.streakAtTime, 0);
      });

      test('ignored when not in showingStock phase', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);

        // Still in loading phase
        notifier.makePrediction(StockDirection.up);

        final state = container.read(gameStateProvider);
        expect(state.phase, GamePhase.loading);
        expect(state.predictions, isEmpty);
      });

      test('streak multiplier applied at hot threshold', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        // Get 3 correct in a row to hit hot threshold
        for (var i = 0; i < 3; i++) {
          final stock = container.read(gameStateProvider).currentStock!;
          notifier.makePrediction(stock.correctDirection);
          if (i < 2) notifier.nextStock();
        }

        final state = container.read(gameStateProvider);
        expect(state.currentStreak, 3);
        // Streak 1 = 100, Streak 2 = 100, Streak 3 = 150 (1.5x)
        expect(state.totalScore, 350);
        expect(state.predictions[2].pointsEarned, 150);
      });
    });

    group('nextStock', () {
      test('advances to next stock', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        final firstStock = container.read(gameStateProvider).currentStock!;
        notifier.makePrediction(firstStock.correctDirection);
        notifier.nextStock();

        final state = container.read(gameStateProvider);
        expect(state.phase, GamePhase.showingStock);
        expect(state.currentStockIndex, 1);
        expect(state.currentStock, isNot(equals(firstStock)));
      });

      test('transitions to roundComplete on last stock', () async {
        final container = _createContainer(stockCount: 2);
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        // Play through 2 stocks
        for (var i = 0; i < 2; i++) {
          final stock = container.read(gameStateProvider).currentStock!;
          notifier.makePrediction(stock.correctDirection);
          notifier.nextStock();
        }

        final state = container.read(gameStateProvider);
        expect(state.phase, GamePhase.roundComplete);
      });

      test('sets finalResult on roundComplete', () async {
        final container = _createContainer(stockCount: 2);
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        for (var i = 0; i < 2; i++) {
          final stock = container.read(gameStateProvider).currentStock!;
          notifier.makePrediction(stock.correctDirection);
          notifier.nextStock();
        }

        final state = container.read(gameStateProvider);
        expect(state.finalResult, isNotNull);
        expect(state.finalResult!.totalScore, state.totalScore);
        expect(state.finalResult!.correctCount, 2);
        expect(state.finalResult!.totalRounds, 2);
        expect(state.finalResult!.bestStreak, 2);
      });

      test('ignored when not in showingResult phase', () async {
        final container = _createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameStateProvider.notifier);
        await notifier.startNewRound();

        // In showingStock phase, nextStock should be ignored
        notifier.nextStock();

        final state = container.read(gameStateProvider);
        expect(state.phase, GamePhase.showingStock);
        expect(state.currentStockIndex, 0);
      });
    });

    test('resetGame returns to initial state', () async {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);
      await notifier.startNewRound();

      final stock = container.read(gameStateProvider).currentStock!;
      notifier.makePrediction(stock.correctDirection);

      // Now reset
      notifier.resetGame();

      final state = container.read(gameStateProvider);
      expect(state.phase, GamePhase.loading);
      expect(state.roundStocks, isEmpty);
      expect(state.predictions, isEmpty);
      expect(state.currentStreak, 0);
      expect(state.totalScore, 0);
      expect(state.finalResult, isNull);
    });

    test('full round lifecycle with all correct', () async {
      final container = _createContainer(stockCount: 10);
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);
      await notifier.startNewRound();

      for (var i = 0; i < 10; i++) {
        final s = container.read(gameStateProvider);
        expect(s.phase, GamePhase.showingStock);
        expect(s.currentStockIndex, i);

        notifier.makePrediction(s.currentStock!.correctDirection);

        final afterPrediction = container.read(gameStateProvider);
        expect(afterPrediction.phase, GamePhase.showingResult);
        expect(afterPrediction.predictions.length, i + 1);

        notifier.nextStock();
      }

      final finalState = container.read(gameStateProvider);
      expect(finalState.phase, GamePhase.roundComplete);
      expect(finalState.finalResult, isNotNull);
      expect(finalState.finalResult!.correctCount, 10);
      expect(finalState.finalResult!.bestStreak, 10);
      // Score: 100+100+150+150+200+200+300+300+300+300 = 2100
      expect(finalState.totalScore, 2100);
    });

    test('streak resets on wrong answer mid-round', () async {
      final container = _createContainer(stockCount: 5);
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);
      await notifier.startNewRound();

      // Stock 0: correct
      var s = container.read(gameStateProvider);
      notifier.makePrediction(s.currentStock!.correctDirection);
      notifier.nextStock();

      // Stock 1: correct
      s = container.read(gameStateProvider);
      notifier.makePrediction(s.currentStock!.correctDirection);
      notifier.nextStock();
      expect(container.read(gameStateProvider).currentStreak, 2);

      // Stock 2: wrong
      s = container.read(gameStateProvider);
      final wrongPick = s.currentStock!.correctDirection == StockDirection.up
          ? StockDirection.down
          : StockDirection.up;
      notifier.makePrediction(wrongPick);
      expect(container.read(gameStateProvider).currentStreak, 0);
      notifier.nextStock();

      // Stock 3: correct (streak restarts at 1)
      s = container.read(gameStateProvider);
      notifier.makePrediction(s.currentStock!.correctDirection);
      expect(container.read(gameStateProvider).currentStreak, 1);
      notifier.nextStock();

      // Stock 4: correct (streak is 2)
      s = container.read(gameStateProvider);
      notifier.makePrediction(s.currentStock!.correctDirection);
      notifier.nextStock();

      final finalState = container.read(gameStateProvider);
      expect(finalState.phase, GamePhase.roundComplete);
      expect(finalState.finalResult!.bestStreak, 2);
      expect(finalState.finalResult!.correctCount, 4);
      // Score: 100+100+0+100+100 = 400
      expect(finalState.totalScore, 400);
    });

    test('makePrediction ignored during showingResult phase', () async {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);
      await notifier.startNewRound();

      final stock = container.read(gameStateProvider).currentStock!;
      notifier.makePrediction(stock.correctDirection);

      // Now in showingResult - another prediction should be ignored
      notifier.makePrediction(StockDirection.up);

      final state = container.read(gameStateProvider);
      expect(state.predictions.length, 1);
    });

    test('play again loop works', () async {
      final container = _createContainer(stockCount: 3);
      addTearDown(container.dispose);
      final notifier = container.read(gameStateProvider.notifier);

      // Play first round
      await notifier.startNewRound();
      for (var i = 0; i < 3; i++) {
        final s = container.read(gameStateProvider);
        notifier.makePrediction(s.currentStock!.correctDirection);
        notifier.nextStock();
      }
      expect(container.read(gameStateProvider).phase, GamePhase.roundComplete);

      // Reset and play again
      notifier.resetGame();
      expect(container.read(gameStateProvider).phase, GamePhase.loading);

      await notifier.startNewRound();
      expect(container.read(gameStateProvider).phase, GamePhase.showingStock);
      expect(container.read(gameStateProvider).totalScore, 0);
      expect(container.read(gameStateProvider).predictions, isEmpty);
    });
  });
}
