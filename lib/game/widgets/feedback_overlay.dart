import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final int pointsEarned;
  final double priceBefore;
  final double priceAfter;
  final VoidCallback onComplete;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.pointsEarned,
    required this.priceBefore,
    required this.priceAfter,
    required this.onComplete,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 0.0–0.15: fade in + scale up
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.15, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.15, curve: Curves.elasticOut)),
    );
    // 0.75–1.0: fade out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.75, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCorrect ? AppColors.stockUp : AppColors.stockDown;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _fadeIn.value * _fadeOut.value;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: _buildContent(color),
    );
  }

  Widget _buildContent(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isCorrect ? Icons.check_circle : Icons.cancel,
            size: 56,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            widget.isCorrect ? 'Correct!' : 'Wrong!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (widget.isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              '+${widget.pointsEarned} pts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '\$${widget.priceBefore.toStringAsFixed(2)} → \$${widget.priceAfter.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
