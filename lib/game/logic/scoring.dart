import '../../core/constants/game_constants.dart';
import '../../data/models/prediction.dart';
import '../../data/models/game_result.dart';

/// Returns the streak multiplier for the given [currentStreak].
double getMultiplier(int currentStreak) {
  if (currentStreak >= GameConstants.unstoppableStreakThreshold) {
    return GameConstants.unstoppableMultiplier;
  } else if (currentStreak >= GameConstants.onFireStreakThreshold) {
    return GameConstants.onFireMultiplier;
  } else if (currentStreak >= GameConstants.hotStreakThreshold) {
    return GameConstants.hotMultiplier;
  }
  return GameConstants.defaultMultiplier;
}

/// Returns the points earned for a correct answer at the given [currentStreak].
int calculatePoints(int currentStreak) {
  return (GameConstants.basePoints * getMultiplier(currentStreak)).round();
}

/// Returns a display label for the current streak, or an empty string
/// if the streak is below the first threshold.
String getStreakLabel(int currentStreak) {
  if (currentStreak >= GameConstants.unstoppableStreakThreshold) {
    return 'Unstoppable!';
  } else if (currentStreak >= GameConstants.onFireStreakThreshold) {
    return 'On Fire!';
  } else if (currentStreak >= GameConstants.hotStreakThreshold) {
    return 'Hot!';
  }
  return '';
}

/// Aggregates a list of [predictions] into a [GameResult].
GameResult calculateGameResult(List<Prediction> predictions) {
  int totalScore = 0;
  int bestStreak = 0;
  int currentStreak = 0;
  int correctCount = 0;

  for (final prediction in predictions) {
    totalScore += prediction.pointsEarned;
    if (prediction.isCorrect) {
      correctCount++;
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }

  return GameResult(
    predictions: predictions,
    totalScore: totalScore,
    bestStreak: bestStreak,
    correctCount: correctCount,
    totalRounds: predictions.length,
    playedAt: DateTime.now(),
  );
}
