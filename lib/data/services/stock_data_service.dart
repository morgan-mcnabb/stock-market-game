import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/stock_csv_parser.dart';
import '../models/stock_round.dart';

class StockDataService {
  final Future<String> Function() _loadCsv;
  Future<List<StockRound>>? _loadFuture;

  StockDataService({Future<String> Function()? loadCsv})
      : _loadCsv =
            loadCsv ?? (() => rootBundle.loadString('assets/data/stock_data.csv'));

  Future<List<StockRound>> _ensureLoaded() {
    return _loadFuture ??= _loadCsv().then(
      (rawCsv) => List<StockRound>.unmodifiable(StockCsvParser.parse(rawCsv)),
    );
  }

  /// Returns [count] random [StockRound]s with no repeats within the result.
  ///
  /// If [count] exceeds the available stock data, returns all available stocks
  /// in a shuffled order.
  Future<List<StockRound>> getRandomRounds(int count, {Random? random}) async {
    final allStocks = await _ensureLoaded();
    if (allStocks.isEmpty) return [];

    final effectiveCount = count.clamp(0, allStocks.length);
    final indices = List<int>.generate(allStocks.length, (i) => i);
    indices.shuffle(random ?? Random());

    return [for (final i in indices.take(effectiveCount)) allStocks[i]];
  }

  /// Returns the total number of available stock rounds.
  Future<int> get stockCount async => (await _ensureLoaded()).length;
}

final stockDataServiceProvider = Provider<StockDataService>((ref) {
  return StockDataService();
});
