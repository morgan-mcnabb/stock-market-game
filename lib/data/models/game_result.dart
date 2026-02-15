import 'prediction.dart';

class GameResult {
  final List<Prediction> predictions;
  final int totalScore;
  final int bestStreak;
  final int correctCount;
  final int totalRounds;
  final DateTime playedAt;

  const GameResult({
    required this.predictions,
    required this.totalScore,
    required this.bestStreak,
    required this.correctCount,
    required this.totalRounds,
    required this.playedAt,
  });

  double get accuracyPercent =>
      totalRounds > 0 ? (correctCount / totalRounds) * 100 : 0;

  String get grade {
    final pct = accuracyPercent;
    if (pct >= 90) return 'A';
    if (pct >= 80) return 'B';
    if (pct >= 70) return 'C';
    if (pct >= 60) return 'D';
    return 'F';
  }

  GameResult copyWith({
    List<Prediction>? predictions,
    int? totalScore,
    int? bestStreak,
    int? correctCount,
    int? totalRounds,
    DateTime? playedAt,
  }) {
    return GameResult(
      predictions: predictions ?? this.predictions,
      totalScore: totalScore ?? this.totalScore,
      bestStreak: bestStreak ?? this.bestStreak,
      correctCount: correctCount ?? this.correctCount,
      totalRounds: totalRounds ?? this.totalRounds,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResult &&
          runtimeType == other.runtimeType &&
          totalScore == other.totalScore &&
          bestStreak == other.bestStreak &&
          correctCount == other.correctCount &&
          totalRounds == other.totalRounds &&
          playedAt == other.playedAt;

  @override
  int get hashCode => Object.hash(
        totalScore,
        bestStreak,
        correctCount,
        totalRounds,
        playedAt,
      );

  @override
  String toString() =>
      'GameResult(score: $totalScore, correct: $correctCount/$totalRounds, streak: $bestStreak, grade: $grade)';
}
