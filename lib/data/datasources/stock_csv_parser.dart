import 'package:csv/csv.dart';
import '../models/stock_round.dart';

class StockCsvParser {
  StockCsvParser._();

  /// Parses raw CSV text into a list of [StockRound] objects.
  ///
  /// Expects a header row matching:
  /// `ticker,company_name,headline,date,price_before,price_after,direction,percent_change`
  ///
  /// Skips the header row, empty lines, and malformed rows.
  static List<StockRound> parse(String rawCsv) {
    final normalized = rawCsv.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    final rows = const CsvToListConverter(eol: '\n').convert(normalized);

    if (rows.isEmpty) return [];

    // Skip header row
    final dataRows = rows.skip(1);

    final results = <StockRound>[];
    for (final row in dataRows) {
      final parsed = _parseRow(row);
      if (parsed != null) {
        results.add(parsed);
      }
    }

    return results;
  }

  static StockRound? _parseRow(List<dynamic> row) {
    // Expect exactly 8 columns
    if (row.length < 8) return null;

    try {
      final ticker = row[0].toString().trim();
      final companyName = row[1].toString().trim();
      final headline = row[2].toString().trim();
      final date = row[3].toString().trim();
      final priceBefore = _toDouble(row[4]);
      final priceAfter = _toDouble(row[5]);
      final directionStr = row[6].toString().trim().toLowerCase();
      final percentChange = _toDouble(row[7]);

      // Validate required fields are not empty
      if (ticker.isEmpty || companyName.isEmpty || headline.isEmpty || date.isEmpty) {
        return null;
      }

      final direction = switch (directionStr) {
        'up' => StockDirection.up,
        'down' => StockDirection.down,
        _ => null,
      };
      if (direction == null) return null;

      return StockRound(
        ticker: ticker,
        companyName: companyName,
        headline: headline,
        date: date,
        priceBefore: priceBefore,
        priceAfter: priceAfter,
        correctDirection: direction,
        percentChange: percentChange,
      );
    } catch (_) {
      // Skip rows that fail to parse (e.g. non-numeric price)
      return null;
    }
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString().trim());
  }
}
