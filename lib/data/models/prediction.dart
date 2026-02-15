import 'stock_round.dart';

class Prediction {
  final StockRound stockRound;
  final StockDirection userPick;
  final bool isCorrect;
  final int pointsEarned;
  final int streakAtTime;

  const Prediction({
    required this.stockRound,
    required this.userPick,
    required this.isCorrect,
    required this.pointsEarned,
    required this.streakAtTime,
  });

  Prediction copyWith({
    StockRound? stockRound,
    StockDirection? userPick,
    bool? isCorrect,
    int? pointsEarned,
    int? streakAtTime,
  }) {
    return Prediction(
      stockRound: stockRound ?? this.stockRound,
      userPick: userPick ?? this.userPick,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      streakAtTime: streakAtTime ?? this.streakAtTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prediction &&
          runtimeType == other.runtimeType &&
          stockRound == other.stockRound &&
          userPick == other.userPick &&
          isCorrect == other.isCorrect &&
          pointsEarned == other.pointsEarned &&
          streakAtTime == other.streakAtTime;

  @override
  int get hashCode => Object.hash(
        stockRound,
        userPick,
        isCorrect,
        pointsEarned,
        streakAtTime,
      );

  @override
  String toString() =>
      'Prediction(ticker: ${stockRound.ticker}, pick: $userPick, correct: $isCorrect, points: $pointsEarned)';
}
