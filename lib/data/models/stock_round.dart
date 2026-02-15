enum StockDirection { up, down }

class StockRound {
  final String ticker;
  final String companyName;
  final String headline;
  final String date;
  final double priceBefore;
  final double priceAfter;
  final StockDirection correctDirection;
  final double percentChange;

  const StockRound({
    required this.ticker,
    required this.companyName,
    required this.headline,
    required this.date,
    required this.priceBefore,
    required this.priceAfter,
    required this.correctDirection,
    required this.percentChange,
  });

  StockRound copyWith({
    String? ticker,
    String? companyName,
    String? headline,
    String? date,
    double? priceBefore,
    double? priceAfter,
    StockDirection? correctDirection,
    double? percentChange,
  }) {
    return StockRound(
      ticker: ticker ?? this.ticker,
      companyName: companyName ?? this.companyName,
      headline: headline ?? this.headline,
      date: date ?? this.date,
      priceBefore: priceBefore ?? this.priceBefore,
      priceAfter: priceAfter ?? this.priceAfter,
      correctDirection: correctDirection ?? this.correctDirection,
      percentChange: percentChange ?? this.percentChange,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockRound &&
          runtimeType == other.runtimeType &&
          ticker == other.ticker &&
          companyName == other.companyName &&
          headline == other.headline &&
          date == other.date &&
          priceBefore == other.priceBefore &&
          priceAfter == other.priceAfter &&
          correctDirection == other.correctDirection &&
          percentChange == other.percentChange;

  @override
  int get hashCode => Object.hash(
        ticker,
        companyName,
        headline,
        date,
        priceBefore,
        priceAfter,
        correctDirection,
        percentChange,
      );

  @override
  String toString() =>
      'StockRound(ticker: $ticker, company: $companyName, direction: $correctDirection, change: $percentChange%)';
}
