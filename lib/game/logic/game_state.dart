import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/game_constants.dart';
import '../../data/models/game_result.dart';
import '../../data/models/prediction.dart';
import '../../data/models/stock_round.dart';
import '../../data/services/stock_data_service.dart';
import 'scoring.dart';

enum GamePhase {
  loading,
  showingStock,
  showingResult,
  roundComplete,
}

class GameState {
  final GamePhase phase;
  final List<StockRound> roundStocks;
  final int currentStockIndex;
  final List<Prediction> predictions;
  final int currentStreak;
  final int totalScore;
  final GameResult? finalResult;

  const GameState({
    this.phase = GamePhase.loading,
    this.roundStocks = const [],
    this.currentStockIndex = 0,
    this.predictions = const [],
    this.currentStreak = 0,
    this.totalScore = 0,
    this.finalResult,
  });

  StockRound? get currentStock =>
      currentStockIndex < roundStocks.length
          ? roundStocks[currentStockIndex]
          : null;

  GameState copyWith({
    GamePhase? phase,
    List<StockRound>? roundStocks,
    int? currentStockIndex,
    List<Prediction>? predictions,
    int? currentStreak,
    int? totalScore,
    GameResult? finalResult,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      roundStocks: roundStocks ?? this.roundStocks,
      currentStockIndex: currentStockIndex ?? this.currentStockIndex,
      predictions: predictions ?? this.predictions,
      currentStreak: currentStreak ?? this.currentStreak,
      totalScore: totalScore ?? this.totalScore,
      finalResult: finalResult ?? this.finalResult,
    );
  }

  @override
  String toString() =>
      'GameState(phase: $phase, stock: ${currentStockIndex + 1}/${roundStocks.length}, '
      'score: $totalScore, streak: $currentStreak)';
}

class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  /// Fetches stocks from the data service and begins a new round.
  Future<void> startNewRound() async {
    state = const GameState(phase: GamePhase.loading);
    final service = ref.read(stockDataServiceProvider);
    final stocks = await service.getRandomRounds(GameConstants.roundSize);
    state = GameState(
      phase: GamePhase.showingStock,
      roundStocks: stocks,
    );
  }

  /// Records the player's prediction and updates score/streak.
  ///
  /// Only valid when [phase] is [GamePhase.showingStock].
  void makePrediction(StockDirection pick) {
    if (state.phase != GamePhase.showingStock) return;
    final stock = state.currentStock;
    if (stock == null) return;

    final isCorrect = pick == stock.correctDirection;
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final points = isCorrect ? calculatePoints(newStreak) : 0;

    final prediction = Prediction(
      stockRound: stock,
      userPick: pick,
      isCorrect: isCorrect,
      pointsEarned: points,
      streakAtTime: newStreak,
    );

    state = state.copyWith(
      phase: GamePhase.showingResult,
      predictions: [...state.predictions, prediction],
      currentStreak: newStreak,
      totalScore: state.totalScore + points,
    );
  }

  /// Advances to the next stock, or completes the round if all stocks are done.
  ///
  /// Only valid when [phase] is [GamePhase.showingResult].
  void nextStock() {
    if (state.phase != GamePhase.showingResult) return;

    final nextIndex = state.currentStockIndex + 1;
    if (nextIndex >= state.roundStocks.length) {
      final result = calculateGameResult(state.predictions);
      state = state.copyWith(
        phase: GamePhase.roundComplete,
        finalResult: result,
      );
    } else {
      state = state.copyWith(
        phase: GamePhase.showingStock,
        currentStockIndex: nextIndex,
      );
    }
  }

  /// Resets the game back to its initial state.
  void resetGame() {
    state = const GameState();
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(
  GameStateNotifier.new,
);
