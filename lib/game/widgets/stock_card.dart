import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/stock_round.dart';

class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.stock});

  final StockRound stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticker and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.ticker, style: theme.textTheme.headlineLarge),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${stock.priceBefore.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('Current Price', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Company name
            Text(stock.companyName, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Divider
            const Divider(),
            const SizedBox(height: 12),

            // Headline label
            Text(
              'LATEST NEWS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.gold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),

            // Headline
            Text(
              '\u201C${stock.headline}\u201D',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Text(stock.date, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
