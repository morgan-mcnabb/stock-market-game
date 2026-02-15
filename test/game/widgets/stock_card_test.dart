import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/data/models/stock_round.dart';
import 'package:stock_market_game/game/widgets/stock_card.dart';

void main() {
  const testStock = StockRound(
    ticker: 'AAPL',
    companyName: 'Apple Inc.',
    headline: 'Apple reports record earnings',
    date: '2024-01-15',
    priceBefore: 150.00,
    priceAfter: 165.00,
    correctDirection: StockDirection.up,
    percentChange: 10.0,
  );

  Widget buildSubject({StockRound stock = testStock}) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: StockCard(stock: stock),
      ),
    );
  }

  group('StockCard', () {
    testWidgets('displays ticker', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('AAPL'), findsOneWidget);
    });

    testWidgets('displays company name', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Apple Inc.'), findsOneWidget);
    });

    testWidgets('displays headline in quotes', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        find.text('\u201CApple reports record earnings\u201D'),
        findsOneWidget,
      );
    });

    testWidgets('displays date', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('2024-01-15'), findsOneWidget);
    });

    testWidgets('displays price_before as current price', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('\$150.00'), findsOneWidget);
      expect(find.text('Current Price'), findsOneWidget);
    });

    testWidgets('does NOT display price_after', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('\$165.00'), findsNothing);
      expect(find.text('165.00'), findsNothing);
    });

    testWidgets('does NOT display direction or percent change', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('up'), findsNothing);
      expect(find.text('10.0'), findsNothing);
      expect(find.text('10.0%'), findsNothing);
    });

    testWidgets('displays LATEST NEWS label', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('LATEST NEWS'), findsOneWidget);
    });

    testWidgets('renders as a Card widget', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with different stock data', (tester) async {
      const otherStock = StockRound(
        ticker: 'GOOG',
        companyName: 'Alphabet Inc.',
        headline: 'Google drops on ad revenue miss',
        date: '2024-02-20',
        priceBefore: 140.50,
        priceAfter: 133.48,
        correctDirection: StockDirection.down,
        percentChange: -5.0,
      );
      await tester.pumpWidget(buildSubject(stock: otherStock));

      expect(find.text('GOOG'), findsOneWidget);
      expect(find.text('Alphabet Inc.'), findsOneWidget);
      expect(
        find.text('\u201CGoogle drops on ad revenue miss\u201D'),
        findsOneWidget,
      );
      expect(find.text('2024-02-20'), findsOneWidget);
      expect(find.text('\$140.50'), findsOneWidget);

      // Should NOT reveal the answer
      expect(find.text('\$133.48'), findsNothing);
      expect(find.text('down'), findsNothing);
      expect(find.text('-5.0'), findsNothing);
    });
  });
}
