import 'package:flutter/material.dart';
import '../game/screens/game_screen.dart';
import '../game/screens/score_summary_screen.dart';

class AppRouter {
  AppRouter._();

  static const String game = '/';
  static const String summary = '/summary';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case game:
        return MaterialPageRoute(settings: settings, builder: (_) => const GameScreen());
      case summary:
        return MaterialPageRoute(settings: settings, builder: (_) => const ScoreSummaryScreen());
      default:
        return MaterialPageRoute(settings: settings, builder: (_) => const GameScreen());
    }
  }
}
