import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/data/services/stock_data_service.dart';

const _testCsv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,Apple reports record earnings,2024-01-15,150.00,165.00,up,10.0
GOOG,Alphabet Inc.,Google drops on ad revenue miss,2024-02-20,140.50,133.48,down,-5.0
MSFT,Microsoft Corp.,Cloud revenue surges,2024-03-10,380.00,395.00,up,3.95
AMZN,Amazon.com Inc.,Prime Day drives sales,2024-04-05,175.00,182.00,up,4.0
TSLA,Tesla Inc.,Delivery numbers disappoint,2024-05-01,200.00,185.00,down,-7.5''';

StockDataService _createService({String csv = _testCsv}) {
  return StockDataService(loadCsv: () async => csv);
}

void main() {
  group('StockDataService', () {
    group('loading and caching', () {
      test('loads and parses CSV data', () async {
        final service = _createService();
        final count = await service.stockCount;
        expect(count, 5);
      });

      test('caches parsed data on subsequent calls', () async {
        var loadCount = 0;
        final service = StockDataService(loadCsv: () async {
          loadCount++;
          return _testCsv;
        });

        await service.stockCount;
        await service.stockCount;
        await service.getRandomRounds(2);

        expect(loadCount, 1);
      });

      test('handles empty CSV', () async {
        final service = _createService(csv: '');
        final count = await service.stockCount;
        expect(count, 0);
      });

      test('handles header-only CSV', () async {
        final service = _createService(
          csv:
              'ticker,company_name,headline,date,price_before,price_after,direction,percent_change',
        );
        final count = await service.stockCount;
        expect(count, 0);
      });
    });

    group('getRandomRounds', () {
      test('returns requested number of rounds', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(3);
        expect(rounds, hasLength(3));
      });

      test('returns all available if count exceeds stock count', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(100);
        expect(rounds, hasLength(5));
      });

      test('returns empty list for count of 0', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(0);
        expect(rounds, isEmpty);
      });

      test('returns empty list for negative count', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(-5);
        expect(rounds, isEmpty);
      });

      test('returns empty list when CSV has no data', () async {
        final service = _createService(csv: '');
        final rounds = await service.getRandomRounds(5);
        expect(rounds, isEmpty);
      });

      test('returns no duplicate rounds within a single call', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(5);
        final tickers = rounds.map((r) => r.ticker).toSet();
        expect(tickers, hasLength(5));
      });

      test('returns StockRound objects with correct data', () async {
        // Use a fixed seed to get deterministic results
        final service = _createService();
        final rounds = await service.getRandomRounds(5, random: Random(42));

        // All 5 tickers should be present (just in shuffled order)
        final tickers = rounds.map((r) => r.ticker).toSet();
        expect(tickers, containsAll(['AAPL', 'GOOG', 'MSFT', 'AMZN', 'TSLA']));
      });

      test('shuffles results (different order with different seeds)', () async {
        final service = _createService();

        final rounds1 = await service.getRandomRounds(5, random: Random(1));
        final rounds2 = await service.getRandomRounds(5, random: Random(999));

        final tickers1 = rounds1.map((r) => r.ticker).toList();
        final tickers2 = rounds2.map((r) => r.ticker).toList();

        // With different seeds, the order should (almost certainly) differ
        // Both should contain the same set of tickers
        expect(tickers1.toSet(), tickers2.toSet());
        // At least one position should differ (extremely unlikely to be same order)
        expect(tickers1, isNot(equals(tickers2)));
      });

      test('requesting exactly 1 round returns a single item', () async {
        final service = _createService();
        final rounds = await service.getRandomRounds(1);
        expect(rounds, hasLength(1));
        expect(rounds[0], isA<StockRound>());
      });

      test('multiple calls can return different orderings', () async {
        final service = _createService();

        final results = <List<String>>[];
        for (var i = 0; i < 10; i++) {
          final rounds = await service.getRandomRounds(5);
          results.add(rounds.map((r) => r.ticker).toList());
        }

        // At least 2 different orderings should appear in 10 tries
        final unique = results.map((r) => r.join(',')).toSet();
        expect(unique.length, greaterThan(1));
      });
    });
  });
}
