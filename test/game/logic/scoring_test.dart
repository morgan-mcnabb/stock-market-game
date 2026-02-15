import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/core/constants/game_constants.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/data/models/prediction.dart';
import 'package:stock_market_game/game/logic/scoring.dart';

/// Helper to build a dummy [StockRound] for testing.
StockRound _dummyStock() {
  return const StockRound(
    ticker: 'TEST',
    companyName: 'Test Corp',
    headline: 'Test headline',
    date: '2025-01-01',
    priceBefore: 100.0,
    priceAfter: 110.0,
    correctDirection: StockDirection.up,
    percentChange: 10.0,
  );
}

/// Helper to build a [Prediction].
Prediction _prediction({
  required bool isCorrect,
  required int pointsEarned,
  int streakAtTime = 0,
}) {
  return Prediction(
    stockRound: _dummyStock(),
    userPick: StockDirection.up,
    isCorrect: isCorrect,
    pointsEarned: pointsEarned,
    streakAtTime: streakAtTime,
  );
}

void main() {
  group('getMultiplier', () {
    test('returns 1.0x for streak 0', () {
      expect(getMultiplier(0), GameConstants.defaultMultiplier);
    });

    test('returns 1.0x for streak 1', () {
      expect(getMultiplier(1), GameConstants.defaultMultiplier);
    });

    test('returns 1.0x for streak 2', () {
      expect(getMultiplier(2), GameConstants.defaultMultiplier);
    });

    test('returns 1.5x at hot threshold (3)', () {
      expect(getMultiplier(3), GameConstants.hotMultiplier);
    });

    test('returns 1.5x for streak 4', () {
      expect(getMultiplier(4), GameConstants.hotMultiplier);
    });

    test('returns 2.0x at on-fire threshold (5)', () {
      expect(getMultiplier(5), GameConstants.onFireMultiplier);
    });

    test('returns 2.0x for streak 6', () {
      expect(getMultiplier(6), GameConstants.onFireMultiplier);
    });

    test('returns 3.0x at unstoppable threshold (7)', () {
      expect(getMultiplier(7), GameConstants.unstoppableMultiplier);
    });

    test('returns 3.0x for streak 10', () {
      expect(getMultiplier(10), GameConstants.unstoppableMultiplier);
    });

    test('returns 3.0x for very high streak', () {
      expect(getMultiplier(100), GameConstants.unstoppableMultiplier);
    });
  });

  group('calculatePoints', () {
    test('returns base points for streak 0', () {
      expect(calculatePoints(0), 100);
    });

    test('returns base points for streak 2', () {
      expect(calculatePoints(2), 100);
    });

    test('returns 150 at hot streak (3)', () {
      expect(calculatePoints(3), 150);
    });

    test('returns 200 at on-fire streak (5)', () {
      expect(calculatePoints(5), 200);
    });

    test('returns 300 at unstoppable streak (7)', () {
      expect(calculatePoints(7), 300);
    });
  });

  group('getStreakLabel', () {
    test('returns empty string for streak 0', () {
      expect(getStreakLabel(0), '');
    });

    test('returns empty string for streak 2', () {
      expect(getStreakLabel(2), '');
    });

    test('returns "Hot!" at streak 3', () {
      expect(getStreakLabel(3), 'Hot!');
    });

    test('returns "Hot!" at streak 4', () {
      expect(getStreakLabel(4), 'Hot!');
    });

    test('returns "On Fire!" at streak 5', () {
      expect(getStreakLabel(5), 'On Fire!');
    });

    test('returns "On Fire!" at streak 6', () {
      expect(getStreakLabel(6), 'On Fire!');
    });

    test('returns "Unstoppable!" at streak 7', () {
      expect(getStreakLabel(7), 'Unstoppable!');
    });

    test('returns "Unstoppable!" at streak 10', () {
      expect(getStreakLabel(10), 'Unstoppable!');
    });
  });

  group('calculateGameResult', () {
    test('handles empty predictions list', () {
      final result = calculateGameResult([]);
      expect(result.totalScore, 0);
      expect(result.bestStreak, 0);
      expect(result.correctCount, 0);
      expect(result.totalRounds, 0);
    });

    test('all correct predictions', () {
      final predictions = List.generate(
        10,
        (i) => _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: i),
      );
      final result = calculateGameResult(predictions);
      expect(result.totalScore, 1000);
      expect(result.bestStreak, 10);
      expect(result.correctCount, 10);
      expect(result.totalRounds, 10);
    });

    test('all wrong predictions', () {
      final predictions = List.generate(
        10,
        (i) => _prediction(isCorrect: false, pointsEarned: 0),
      );
      final result = calculateGameResult(predictions);
      expect(result.totalScore, 0);
      expect(result.bestStreak, 0);
      expect(result.correctCount, 0);
      expect(result.totalRounds, 10);
    });

    test('mixed predictions track best streak correctly', () {
      // Pattern: correct, correct, wrong, correct, correct, correct, wrong
      final predictions = [
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 2),
        _prediction(isCorrect: false, pointsEarned: 0, streakAtTime: 0),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 2),
        _prediction(isCorrect: true, pointsEarned: 150, streakAtTime: 3),
        _prediction(isCorrect: false, pointsEarned: 0, streakAtTime: 0),
      ];
      final result = calculateGameResult(predictions);
      expect(result.totalScore, 550);
      expect(result.bestStreak, 3);
      expect(result.correctCount, 5);
      expect(result.totalRounds, 7);
    });

    test('streak resets after wrong answer', () {
      final predictions = [
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
        _prediction(isCorrect: false, pointsEarned: 0, streakAtTime: 0),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
      ];
      final result = calculateGameResult(predictions);
      expect(result.bestStreak, 1);
      expect(result.correctCount, 2);
      expect(result.totalScore, 200);
    });

    test('single correct prediction', () {
      final result = calculateGameResult([
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
      ]);
      expect(result.totalScore, 100);
      expect(result.bestStreak, 1);
      expect(result.correctCount, 1);
      expect(result.totalRounds, 1);
    });

    test('single wrong prediction', () {
      final result = calculateGameResult([
        _prediction(isCorrect: false, pointsEarned: 0),
      ]);
      expect(result.totalScore, 0);
      expect(result.bestStreak, 0);
      expect(result.correctCount, 0);
      expect(result.totalRounds, 1);
    });

    test('best streak is at the end', () {
      // wrong, correct, correct, correct, correct
      final predictions = [
        _prediction(isCorrect: false, pointsEarned: 0),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 1),
        _prediction(isCorrect: true, pointsEarned: 100, streakAtTime: 2),
        _prediction(isCorrect: true, pointsEarned: 150, streakAtTime: 3),
        _prediction(isCorrect: true, pointsEarned: 150, streakAtTime: 4),
      ];
      final result = calculateGameResult(predictions);
      expect(result.bestStreak, 4);
      expect(result.correctCount, 4);
      expect(result.totalScore, 500);
    });

    test('predictions list is preserved in result', () {
      final predictions = [
        _prediction(isCorrect: true, pointsEarned: 100),
        _prediction(isCorrect: false, pointsEarned: 0),
      ];
      final result = calculateGameResult(predictions);
      expect(result.predictions, predictions);
    });

    test('playedAt is set to a recent timestamp', () {
      final before = DateTime.now();
      final result = calculateGameResult([]);
      final after = DateTime.now();
      expect(result.playedAt.isAfter(before) || result.playedAt.isAtSameMomentAs(before), isTrue);
      expect(result.playedAt.isBefore(after) || result.playedAt.isAtSameMomentAs(after), isTrue);
    });
  });
}
