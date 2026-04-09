class AppConstants {
  static const String appName = 'XO Master';
  static const String appTagline = 'Tic Tac Toe';
  static const int boardSize = 3;
  static const Duration aiDelay = Duration(milliseconds: 600);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration winAnimationDuration = Duration(milliseconds: 500);
}

enum Player { x, o, none }

enum GameMode { pvp, pvai }

enum Difficulty { easy, medium }

enum GameState { playing, won, draw }
