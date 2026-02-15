import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/game_result.dart';
import '../../data/models/prediction.dart';
import '../../data/models/stock_round.dart';
import '../../navigation/app_router.dart';
import '../logic/game_state.dart';

class ScoreSummaryScreen extends ConsumerWidget {
  const ScoreSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final result = gameState.finalResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Round Complete')),
        body: const Center(child: Text('No results available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Round Complete')),
      body: SafeArea(
        child: Column(
          children: [
            // Stats header
            _StatsHeader(result: result),
            const Divider(height: 1),
            // Prediction history
            Expanded(
              child: _PredictionHistory(predictions: result.predictions),
            ),
            // Play Again button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.game,
                      (_) => false,
                    );
                  },
                  child: const Text('Play Again'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.result});

  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // Grade badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gradeColor(result.grade).withValues(alpha: 0.15),
              border: Border.all(
                color: _gradeColor(result.grade),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                result.grade,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _gradeColor(result.grade),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Animated score
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: result.totalScore),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Text(
                '$value pts',
                style: theme.textTheme.titleLarge,
              );
            },
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'Correct',
                value: '${result.correctCount}/${result.totalRounds}',
              ),
              _StatItem(
                label: 'Accuracy',
                value: '${result.accuracyPercent.toStringAsFixed(0)}%',
              ),
              _StatItem(
                label: 'Best Streak',
                value: '${result.bestStreak}',
                icon: result.bestStreak >= 3
                    ? Icons.local_fire_department
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _gradeColor(String grade) {
    return switch (grade) {
      'A' => AppColors.stockUp,
      'B' => const Color(0xFF69F0AE),
      'C' => AppColors.gold,
      'D' => const Color(0xFFFF9100),
      _ => AppColors.stockDown,
    };
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.gold),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PredictionHistory extends StatelessWidget {
  const _PredictionHistory({required this.predictions});

  final List<Prediction> predictions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: predictions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return _PredictionRow(
          prediction: prediction,
        );
      },
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({
    required this.prediction,
  });

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final isCorrect = prediction.isCorrect;
    final color = isCorrect ? AppColors.stockUp : AppColors.stockDown;
    final pickIcon = prediction.userPick == StockDirection.up
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Result icon
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          // Ticker and pick direction
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.stockRound.ticker,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(pickIcon, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      prediction.userPick == StockDirection.up ? 'UP' : 'DOWN',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points earned
          Text(
            '+${prediction.pointsEarned}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isCorrect ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
