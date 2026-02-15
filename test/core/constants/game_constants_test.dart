import 'package:flutter_test/flutter_test.dart';
import 'package:stock_market_game/core/constants/game_constants.dart';

void main() {
  group('GameConstants', () {
    test('roundSize is 10', () {
      expect(GameConstants.roundSize, 10);
    });

    test('basePoints is 100', () {
      expect(GameConstants.basePoints, 100);
    });

    test('streak thresholds are in ascending order', () {
      expect(GameConstants.hotStreakThreshold, lessThan(GameConstants.onFireStreakThreshold));
      expect(GameConstants.onFireStreakThreshold, lessThan(GameConstants.unstoppableStreakThreshold));
    });

    test('multipliers increase with streak tier', () {
      expect(GameConstants.defaultMultiplier, lessThan(GameConstants.hotMultiplier));
      expect(GameConstants.hotMultiplier, lessThan(GameConstants.onFireMultiplier));
      expect(GameConstants.onFireMultiplier, lessThan(GameConstants.unstoppableMultiplier));
    });

    test('default multiplier is 1.0', () {
      expect(GameConstants.defaultMultiplier, 1.0);
    });
  });
}
