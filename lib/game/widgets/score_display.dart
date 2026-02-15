import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../logic/scoring.dart';

class ScoreDisplay extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int totalScore;
  final int currentStreak;

  const ScoreDisplay({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.totalScore,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final streakLabel = getStreakLabel(currentStreak);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Round progress
        Text(
          '$currentRound/$totalRounds',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        // Streak
        if (streakLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, size: 16, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak $streakLabel',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        // Total score
        Text(
          '$totalScore pts',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
