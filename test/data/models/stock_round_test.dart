import 'package:flutter_test/flutter_test.dart';
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

  group('StockDirection', () {
    test('has up and down values', () {
      expect(StockDirection.values, hasLength(2));
      expect(StockDirection.values, contains(StockDirection.up));
      expect(StockDirection.values, contains(StockDirection.down));
    });
  });

  group('StockRound', () {
    test('stores all fields correctly', () {
      expect(round.ticker, 'AAPL');
      expect(round.companyName, 'Apple Inc.');
      expect(round.headline, 'Apple reports record earnings');
      expect(round.date, '2024-01-15');
      expect(round.priceBefore, 150.0);
      expect(round.priceAfter, 165.0);
      expect(round.correctDirection, StockDirection.up);
      expect(round.percentChange, 10.0);
    });

    test('equality works for identical values', () {
      const other = StockRound(
        ticker: 'AAPL',
        companyName: 'Apple Inc.',
        headline: 'Apple reports record earnings',
        date: '2024-01-15',
        priceBefore: 150.0,
        priceAfter: 165.0,
        correctDirection: StockDirection.up,
        percentChange: 10.0,
      );
      expect(round, equals(other));
      expect(round.hashCode, equals(other.hashCode));
    });

    test('inequality for different values', () {
      final other = round.copyWith(ticker: 'GOOG');
      expect(round, isNot(equals(other)));
    });

    test('copyWith replaces specified fields', () {
      final modified = round.copyWith(
        ticker: 'GOOG',
        companyName: 'Alphabet Inc.',
        percentChange: -5.0,
        correctDirection: StockDirection.down,
      );
      expect(modified.ticker, 'GOOG');
      expect(modified.companyName, 'Alphabet Inc.');
      expect(modified.percentChange, -5.0);
      expect(modified.correctDirection, StockDirection.down);
      // Unchanged fields
      expect(modified.headline, round.headline);
      expect(modified.date, round.date);
      expect(modified.priceBefore, round.priceBefore);
      expect(modified.priceAfter, round.priceAfter);
    });

    test('copyWith with no args returns equal copy', () {
      final copy = round.copyWith();
      expect(copy, equals(round));
    });

    test('toString contains key info', () {
      final str = round.toString();
      expect(str, contains('AAPL'));
      expect(str, contains('Apple Inc.'));
    });
  });
}
