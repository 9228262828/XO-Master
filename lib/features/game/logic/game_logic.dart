import 'dart:math';
import '../../../core/constants.dart';

class WinResult {
  final Player winner;
  final List<int> winningLine;

  const WinResult({required this.winner, required this.winningLine});
}

class GameLogic {
  static const List<List<int>> winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6],             // diagonals
  ];

  static WinResult? checkWinner(List<Player> board) {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];
      if (a != Player.none && a == b && b == c) {
        return WinResult(winner: a, winningLine: pattern);
      }
    }
    return null;
  }

  static bool isDraw(List<Player> board) {
    return !board.contains(Player.none) && checkWinner(board) == null;
  }

  static List<int> availableMoves(List<Player> board) {
    return [for (int i = 0; i < 9; i++) if (board[i] == Player.none) i];
  }
}

class AIPlayer {
  final Difficulty difficulty;
  final Random _random = Random();

  AIPlayer({required this.difficulty});

  int getMove(List<Player> board, Player aiPlayer) {
    switch (difficulty) {
      case Difficulty.easy:
        return _getEasyMove(board, aiPlayer);
      case Difficulty.medium:
        return _getMediumMove(board, aiPlayer);
    }
  }

  int _getEasyMove(List<Player> board, Player aiPlayer) {
    // 40% chance of making the best move, 60% random
    if (_random.nextDouble() < 0.4) {
      return _getBestMove(board, aiPlayer);
    }
    final moves = GameLogic.availableMoves(board);
    return moves[_random.nextInt(moves.length)];
  }

  int _getMediumMove(List<Player> board, Player aiPlayer) {
    // 80% chance of making the best move, 20% random
    if (_random.nextDouble() < 0.8) {
      return _getBestMove(board, aiPlayer);
    }
    final moves = GameLogic.availableMoves(board);
    return moves[_random.nextInt(moves.length)];
  }

  int _getBestMove(List<Player> board, Player aiPlayer) {
    final opponent = aiPlayer == Player.x ? Player.o : Player.x;
    int bestScore = -1000;
    int bestMove = -1;

    for (final move in GameLogic.availableMoves(board)) {
      board[move] = aiPlayer;
      int score = _minimax(board, 0, false, aiPlayer, opponent, -1000, 1000);
      board[move] = Player.none;
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _minimax(List<Player> board, int depth, bool isMaximizing,
      Player aiPlayer, Player opponent, int alpha, int beta) {
    final result = GameLogic.checkWinner(board);
    if (result != null) {
      return result.winner == aiPlayer ? 10 - depth : depth - 10;
    }
    if (GameLogic.isDraw(board)) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (final move in GameLogic.availableMoves(board)) {
        board[move] = aiPlayer;
        best = max(best, _minimax(board, depth + 1, false, aiPlayer, opponent, alpha, beta));
        board[move] = Player.none;
        alpha = max(alpha, best);
        if (beta <= alpha) break;
      }
      return best;
    } else {
      int best = 1000;
      for (final move in GameLogic.availableMoves(board)) {
        board[move] = opponent;
        best = min(best, _minimax(board, depth + 1, true, aiPlayer, opponent, alpha, beta));
        board[move] = Player.none;
        beta = min(beta, best);
        if (beta <= alpha) break;
      }
      return best;
    }
  }
}
