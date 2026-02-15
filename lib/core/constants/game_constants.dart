class GameConstants {
  GameConstants._();

  static const int roundSize = 10;
  static const int basePoints = 100;

  // Streak multiplier thresholds
  static const int hotStreakThreshold = 3;
  static const int onFireStreakThreshold = 5;
  static const int unstoppableStreakThreshold = 7;

  static const double hotMultiplier = 1.5;
  static const double onFireMultiplier = 2.0;
  static const double unstoppableMultiplier = 3.0;
  static const double defaultMultiplier = 1.0;
}
