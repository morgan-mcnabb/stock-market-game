import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/stock_round.dart';

class PredictionButtons extends StatelessWidget {
  final ValueChanged<StockDirection> onPrediction;
  final bool enabled;

  const PredictionButtons({
    super.key,
    required this.onPrediction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DirectionButton(
            color: AppColors.stockUp,
            icon: Icons.trending_up,
            label: 'UP',
            onTap: enabled ? () => onPrediction(StockDirection.up) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DirectionButton(
            color: AppColors.stockDown,
            icon: Icons.trending_down,
            label: 'DOWN',
            onTap: enabled ? () => onPrediction(StockDirection.down) : null,
          ),
        ),
      ],
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DirectionButton({
    required this.color,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: color.withValues(alpha: isEnabled ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.3),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: isEnabled ? 0.6 : 0.2),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
