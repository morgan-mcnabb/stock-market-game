import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/datasources/stock_csv_parser.dart';
import 'package:stock_market_game/data/models/stock_round.dart';

void main() {
  group('StockCsvParser', () {
    const validCsv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,Apple reports record earnings,2024-01-15,150.00,165.00,up,10.0
GOOG,Alphabet Inc.,Google drops on ad revenue miss,2024-02-20,140.50,133.48,down,-5.0''';

    test('parses valid CSV with header row', () {
      final results = StockCsvParser.parse(validCsv);
      expect(results, hasLength(2));
    });

    test('first row fields are parsed correctly', () {
      final results = StockCsvParser.parse(validCsv);
      final apple = results[0];

      expect(apple.ticker, 'AAPL');
      expect(apple.companyName, 'Apple Inc.');
      expect(apple.headline, 'Apple reports record earnings');
      expect(apple.date, '2024-01-15');
      expect(apple.priceBefore, 150.00);
      expect(apple.priceAfter, 165.00);
      expect(apple.correctDirection, StockDirection.up);
      expect(apple.percentChange, 10.0);
    });

    test('second row direction is parsed as down', () {
      final results = StockCsvParser.parse(validCsv);
      final google = results[1];

      expect(google.ticker, 'GOOG');
      expect(google.correctDirection, StockDirection.down);
      expect(google.percentChange, -5.0);
    });

    test('skips header row', () {
      const headerOnly =
          'ticker,company_name,headline,date,price_before,price_after,direction,percent_change';
      final results = StockCsvParser.parse(headerOnly);
      expect(results, isEmpty);
    });

    test('handles empty input', () {
      final results = StockCsvParser.parse('');
      expect(results, isEmpty);
    });

    test('handles whitespace-only input', () {
      final results = StockCsvParser.parse('   \n  \n  ');
      expect(results, isEmpty);
    });

    test('skips rows with too few columns', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline
GOOG,Alphabet Inc.,Google drops,2024-02-20,140.50,133.48,down,-5.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(1));
      expect(results[0].ticker, 'GOOG');
    });

    test('skips rows with invalid direction', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline,2024-01-15,150.00,165.00,sideways,10.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, isEmpty);
    });

    test('skips rows with non-numeric price', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline,2024-01-15,not_a_price,165.00,up,10.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, isEmpty);
    });

    test('skips rows with empty ticker', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
,Apple Inc.,headline,2024-01-15,150.00,165.00,up,10.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, isEmpty);
    });

    test('skips rows with empty company name', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,,headline,2024-01-15,150.00,165.00,up,10.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, isEmpty);
    });

    test('handles trailing newlines', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline,2024-01-15,150.00,165.00,up,10.0

''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(1));
    });

    test('handles mixed valid and invalid rows', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,Good earnings,2024-01-15,150.00,165.00,up,10.0
BAD,Bad Row
GOOG,Alphabet Inc.,Ad miss,2024-02-20,140.50,133.48,down,-5.0
,,,,,,invalid,
MSFT,Microsoft Corp.,Cloud growth,2024-03-10,380.00,395.00,up,3.95''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(3));
      expect(results[0].ticker, 'AAPL');
      expect(results[1].ticker, 'GOOG');
      expect(results[2].ticker, 'MSFT');
    });

    test('handles integer prices (no decimal point)', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline,2024-01-15,150,165,up,10''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(1));
      expect(results[0].priceBefore, 150.0);
      expect(results[0].priceAfter, 165.0);
      expect(results[0].percentChange, 10.0);
    });

    test('direction parsing is case-insensitive', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,Apple Inc.,headline,2024-01-15,150.00,165.00,UP,10.0
GOOG,Alphabet Inc.,headline,2024-02-20,140.50,133.48,Down,-5.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(2));
      expect(results[0].correctDirection, StockDirection.up);
      expect(results[1].correctDirection, StockDirection.down);
    });

    test('handles headlines with commas (quoted fields)', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
AAPL,"Apple Inc.","Apple reports record earnings, beats estimates",2024-01-15,150.00,165.00,up,10.0''';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(1));
      expect(results[0].headline, 'Apple reports record earnings, beats estimates');
    });

    test('negative percent change is preserved', () {
      const csv = '''ticker,company_name,headline,date,price_before,price_after,direction,percent_change
GOOG,Alphabet Inc.,Drops hard,2024-02-20,140.50,119.42,down,-15.0''';
      final results = StockCsvParser.parse(csv);
      expect(results[0].percentChange, -15.0);
    });

    test('handles CRLF (\\r\\n) line endings', () {
      const csv =
          'ticker,company_name,headline,date,price_before,price_after,direction,percent_change\r\n'
          'AAPL,Apple Inc.,Good earnings,2024-01-15,150.00,165.00,up,10.0\r\n'
          'GOOG,Alphabet Inc.,Ad miss,2024-02-20,140.50,133.48,down,-5.0\r\n';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(2));
      expect(results[0].ticker, 'AAPL');
      expect(results[0].percentChange, 10.0);
      expect(results[1].ticker, 'GOOG');
      expect(results[1].correctDirection, StockDirection.down);
      expect(results[1].percentChange, -5.0);
    });

    test('handles bare CR (\\r) line endings', () {
      const csv =
          'ticker,company_name,headline,date,price_before,price_after,direction,percent_change\r'
          'AAPL,Apple Inc.,headline,2024-01-15,150.00,165.00,up,10.0\r';
      final results = StockCsvParser.parse(csv);
      expect(results, hasLength(1));
      expect(results[0].ticker, 'AAPL');
    });
  });
}
