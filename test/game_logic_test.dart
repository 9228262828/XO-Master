import 'package:flutter_test/flutter_test.dart';
import 'package:xo_master/core/constants.dart';
import 'package:xo_master/features/game/logic/game_logic.dart';

void main() {
  group('GameLogic', () {
    test('detects horizontal win', () {
      final board = [
        Player.x, Player.x, Player.x,
        Player.none, Player.o, Player.none,
        Player.o, Player.none, Player.none,
      ];
      final result = GameLogic.checkWinner(board);
      expect(result, isNotNull);
      expect(result!.winner, Player.x);
      expect(result.winningLine, [0, 1, 2]);
    });

    test('detects vertical win', () {
      final board = [
        Player.o, Player.x, Player.none,
        Player.o, Player.x, Player.none,
        Player.o, Player.none, Player.x,
      ];
      final result = GameLogic.checkWinner(board);
      expect(result, isNotNull);
      expect(result!.winner, Player.o);
      expect(result.winningLine, [0, 3, 6]);
    });

    test('detects diagonal win', () {
      final board = [
        Player.x, Player.o, Player.none,
        Player.none, Player.x, Player.o,
        Player.none, Player.none, Player.x,
      ];
      final result = GameLogic.checkWinner(board);
      expect(result, isNotNull);
      expect(result!.winner, Player.x);
      expect(result.winningLine, [0, 4, 8]);
    });

    test('detects draw', () {
      final board = [
        Player.x, Player.o, Player.x,
        Player.x, Player.o, Player.o,
        Player.o, Player.x, Player.x,
      ];
      expect(GameLogic.checkWinner(board), isNull);
      expect(GameLogic.isDraw(board), true);
    });

    test('no winner on empty board', () {
      final board = List.filled(9, Player.none);
      expect(GameLogic.checkWinner(board), isNull);
      expect(GameLogic.isDraw(board), false);
    });

    test('available moves returns correct indices', () {
      final board = [
        Player.x, Player.none, Player.x,
        Player.none, Player.o, Player.none,
        Player.o, Player.none, Player.x,
      ];
      expect(GameLogic.availableMoves(board), [1, 3, 5, 7]);
    });
  });

  group('AIPlayer', () {
    test('AI returns a valid move', () {
      final ai = AIPlayer(difficulty: Difficulty.easy);
      final board = [
        Player.x, Player.none, Player.x,
        Player.none, Player.o, Player.none,
        Player.o, Player.none, Player.none,
      ];
      final move = ai.getMove(board, Player.o);
      expect(board[move], Player.none);
    });

    test('AI blocks winning move', () {
      final ai = AIPlayer(difficulty: Difficulty.medium);
      final board = [
        Player.x, Player.x, Player.none,
        Player.o, Player.none, Player.none,
        Player.none, Player.none, Player.none,
      ];
      // Run multiple times since medium has 80% chance of best move
      int blockCount = 0;
      for (int i = 0; i < 20; i++) {
        final testBoard = List<Player>.from(board);
        final move = ai.getMove(testBoard, Player.o);
        if (move == 2) blockCount++;
      }
      expect(blockCount, greaterThan(10));
    });
  });
}
