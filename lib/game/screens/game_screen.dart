import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/app_router.dart';
import '../logic/game_state.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/prediction_buttons.dart';
import '../widgets/score_display.dart';
import '../widgets/stock_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  Future<void> _startRound() async {
    setState(() => _error = null);
    try {
      await ref.read(gameStateProvider.notifier).startNewRound();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    ref.listen<GameState>(gameStateProvider, (prev, next) {
      if (next.phase == GamePhase.roundComplete) {
        Navigator.pushReplacementNamed(context, AppRouter.summary);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Market Game')),
      body: _error != null ? _buildError() : _buildBody(gameState),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load stock data'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startRound,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GameState state) {
    switch (state.phase) {
      case GamePhase.loading:
        return const Center(child: CircularProgressIndicator());
      case GamePhase.showingStock:
      case GamePhase.showingResult:
        return _buildGameContent(state);
      case GamePhase.roundComplete:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildGameContent(GameState state) {
    final stock = state.currentStock;
    if (stock == null) return const SizedBox.shrink();

    final isShowingResult = state.phase == GamePhase.showingResult;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ScoreDisplay(
              currentRound: state.currentStockIndex + 1,
              totalRounds: state.roundStocks.length,
              totalScore: state.totalScore,
              currentStreak: state.currentStreak,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    StockCard(stock: stock),
                    if (isShowingResult)
                      FeedbackOverlay(
                        isCorrect: state.predictions.last.isCorrect,
                        pointsEarned: state.predictions.last.pointsEarned,
                        priceBefore: stock.priceBefore,
                        priceAfter: stock.priceAfter,
                        onComplete: () {
                          ref.read(gameStateProvider.notifier).nextStock();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            PredictionButtons(
              onPrediction: (direction) {
                ref.read(gameStateProvider.notifier).makePrediction(direction);
              },
              enabled: !isShowingResult,
            ),
          ],
        ),
      ),
    );
  }
}
