import 'package:flutter_test/flutter_test.dart';
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

  const prediction = Prediction(
    stockRound: round,
    userPick: StockDirection.up,
    isCorrect: true,
    pointsEarned: 150,
    streakAtTime: 3,
  );

  group('Prediction', () {
    test('stores all fields correctly', () {
      expect(prediction.stockRound, round);
      expect(prediction.userPick, StockDirection.up);
      expect(prediction.isCorrect, true);
      expect(prediction.pointsEarned, 150);
      expect(prediction.streakAtTime, 3);
    });

    test('equality works for identical values', () {
      const other = Prediction(
        stockRound: round,
        userPick: StockDirection.up,
        isCorrect: true,
        pointsEarned: 150,
        streakAtTime: 3,
      );
      expect(prediction, equals(other));
      expect(prediction.hashCode, equals(other.hashCode));
    });

    test('inequality for different user pick', () {
      final other = prediction.copyWith(userPick: StockDirection.down);
      expect(prediction, isNot(equals(other)));
    });

    test('wrong prediction has 0 points', () {
      const wrong = Prediction(
        stockRound: round,
        userPick: StockDirection.down,
        isCorrect: false,
        pointsEarned: 0,
        streakAtTime: 0,
      );
      expect(wrong.isCorrect, false);
      expect(wrong.pointsEarned, 0);
    });

    test('copyWith replaces specified fields', () {
      final modified = prediction.copyWith(
        pointsEarned: 300,
        streakAtTime: 7,
      );
      expect(modified.pointsEarned, 300);
      expect(modified.streakAtTime, 7);
      expect(modified.stockRound, prediction.stockRound);
      expect(modified.userPick, prediction.userPick);
    });

    test('toString contains key info', () {
      final str = prediction.toString();
      expect(str, contains('AAPL'));
      expect(str, contains('up'));
      expect(str, contains('true'));
    });
  });
}
