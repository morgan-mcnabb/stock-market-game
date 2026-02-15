import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stock_market_game/app.dart';
import 'package:stock_market_game/data/services/stock_data_service.dart';

const _testCsv = 'ticker,company_name,headline,date,price_before,price_after,direction,percent_change\n'
    'AAPL,Apple Inc.,Apple jumps on earnings,2025-01-01,150.0,160.0,up,6.67';

void main() {
  testWidgets('App launches and shows game screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockDataServiceProvider.overrideWithValue(
            StockDataService(loadCsv: () async => _testCsv),
          ),
        ],
        child: const App(),
      ),
    );

    expect(find.text('Stock Market Game'), findsOneWidget);
    // Initially shows loading spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After stocks load, shows stock card and buttons
    await tester.pumpAndSettle();
    expect(find.text('AAPL'), findsOneWidget);
    expect(find.text('UP'), findsOneWidget);
    expect(find.text('DOWN'), findsOneWidget);
  });

  testWidgets('Full game flow: play round then navigate to summary',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockDataServiceProvider.overrideWithValue(
            StockDataService(loadCsv: () async => _testCsv),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // Make prediction on the single stock
    await tester.tap(find.text('UP'));
    await tester.pumpAndSettle();

    // Should navigate to summary screen
    expect(find.text('Round Complete'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);

    // Tap "Play Again" to navigate back to game
    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();

    expect(find.text('Stock Market Game'), findsOneWidget);
  });
}
