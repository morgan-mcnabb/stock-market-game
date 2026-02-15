import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/game_result.dart';
import 'package:stock_market_game/data/models/prediction.dart';
import 'package:stock_market_game/data/models/stock_round.dart';

void main() {
  const round = StockRound(
    ticker: 'AAPL',
    companyName: 'Apple Inc.',
    headline: 'Apple reports record earnings',
    date: '2024-01-15',
    priceBefore: 150.0,
    priceAfter: 165.0,
    correctDirection: StockDirection.up,
    percentChange: 10.0,
  );

  final now = DateTime(2024, 6, 15);

  final result = GameResult(
    predictions: const [
      Prediction(
        stockRound: round,
        userPick: StockDirection.up,
        isCorrect: true,
        pointsEarned: 100,
        streakAtTime: 1,
      ),
      Prediction(
        stockRound: round,
        userPick: StockDirection.down,
        isCorrect: false,
        pointsEarned: 0,
        streakAtTime: 0,
      ),
    ],
    totalScore: 100,
    bestStreak: 1,
    correctCount: 1,
    totalRounds: 2,
    playedAt: now,
  );

  group('GameResult', () {
    test('stores all fields correctly', () {
      expect(result.predictions, hasLength(2));
      expect(result.totalScore, 100);
      expect(result.bestStreak, 1);
      expect(result.correctCount, 1);
      expect(result.totalRounds, 2);
      expect(result.playedAt, now);
    });

    test('accuracyPercent calculates correctly', () {
      expect(result.accuracyPercent, 50.0);
    });

    test('accuracyPercent is 0 when totalRounds is 0', () {
      final empty = result.copyWith(correctCount: 0, totalRounds: 0);
      expect(empty.accuracyPercent, 0);
    });

    test('accuracyPercent is 100 for perfect score', () {
      final perfect = result.copyWith(correctCount: 10, totalRounds: 10);
      expect(perfect.accuracyPercent, 100.0);
    });

    test('grade A for 90%+', () {
      final r = result.copyWith(correctCount: 9, totalRounds: 10);
      expect(r.grade, 'A');
    });

    test('grade A for 100%', () {
      final r = result.copyWith(correctCount: 10, totalRounds: 10);
      expect(r.grade, 'A');
    });

    test('grade B for 80-89%', () {
      final r = result.copyWith(correctCount: 8, totalRounds: 10);
      expect(r.grade, 'B');
    });

    test('grade C for 70-79%', () {
      final r = result.copyWith(correctCount: 7, totalRounds: 10);
      expect(r.grade, 'C');
    });

    test('grade D for 60-69%', () {
      final r = result.copyWith(correctCount: 6, totalRounds: 10);
      expect(r.grade, 'D');
    });

    test('grade F for below 60%', () {
      final r = result.copyWith(correctCount: 5, totalRounds: 10);
      expect(r.grade, 'F');
    });

    test('equality works for identical values', () {
      final other = GameResult(
        predictions: result.predictions,
        totalScore: 100,
        bestStreak: 1,
        correctCount: 1,
        totalRounds: 2,
        playedAt: now,
      );
      expect(result, equals(other));
      expect(result.hashCode, equals(other.hashCode));
    });

    test('copyWith replaces specified fields', () {
      final modified = result.copyWith(totalScore: 500, bestStreak: 5);
      expect(modified.totalScore, 500);
      expect(modified.bestStreak, 5);
      expect(modified.correctCount, result.correctCount);
    });

    test('toString contains key info', () {
      final str = result.toString();
      expect(str, contains('100'));
      expect(str, contains('1/2'));
    });
  });
}
