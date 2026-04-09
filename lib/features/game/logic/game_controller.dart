import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import 'game_logic.dart';

class GameController extends ChangeNotifier {
  List<Player> _board = List.filled(9, Player.none);
  Player _currentPlayer = Player.x;
  Player _winner = Player.none;
  GameState _gameState = GameState.playing;
  GameMode _gameMode = GameMode.pvp;
  Difficulty _difficulty = Difficulty.easy;
  List<int> _winningLine = [];
  int _scoreX = 0;
  int _scoreO = 0;
  int _draws = 0;
  bool _isAiThinking = false;
  AIPlayer? _aiPlayer;

  List<Player> get board => List.unmodifiable(_board);
  Player get currentPlayer => _currentPlayer;
  Player get winner => _winner;
  GameState get gameState => _gameState;
  GameMode get gameMode => _gameMode;
  Difficulty get difficulty => _difficulty;
  List<int> get winningLine => _winningLine;
  int get scoreX => _scoreX;
  int get scoreO => _scoreO;
  int get draws => _draws;
  bool get isAiThinking => _isAiThinking;

  String get statusMessage {
    switch (_gameState) {
      case GameState.won:
        if (_gameMode == GameMode.pvai) {
          return _winner == Player.x ? 'You Win!' : 'AI Wins!';
        }
        return '${_winner == Player.x ? "X" : "O"} Wins!';
      case GameState.draw:
        return "It's a Draw!";
      case GameState.playing:
        if (_gameMode == GameMode.pvai && _currentPlayer == Player.o) {
          return 'AI is thinking...';
        }
        return '${_currentPlayer == Player.x ? "X" : "O"}\'s Turn';
    }
  }

  void setGameMode(GameMode mode) {
    _gameMode = mode;
    if (mode == GameMode.pvai) {
      _aiPlayer = AIPlayer(difficulty: _difficulty);
    }
    resetScores();
  }

  void setDifficulty(Difficulty diff) {
    _difficulty = diff;
    if (_gameMode == GameMode.pvai) {
      _aiPlayer = AIPlayer(difficulty: diff);
    }
    resetScores();
  }

  void resetScores() {
    _scoreX = 0;
    _scoreO = 0;
    _draws = 0;
    _resetBoard();
  }

  void _resetBoard() {
    _board = List.filled(9, Player.none);
    _currentPlayer = Player.x;
    _winner = Player.none;
    _gameState = GameState.playing;
    _winningLine = [];
    _isAiThinking = false;
    notifyListeners();
  }

  void newGame() {
    _resetBoard();
  }

  void makeMove(int index) {
    if (_board[index] != Player.none ||
        _gameState != GameState.playing ||
        _isAiThinking) {
      return;
    }

    _board[index] = _currentPlayer;

    final result = GameLogic.checkWinner(_board);
    if (result != null) {
      _gameState = GameState.won;
      _winner = result.winner;
      _winningLine = result.winningLine;
      if (result.winner == Player.x) {
        _scoreX++;
      } else {
        _scoreO++;
      }
      notifyListeners();
      return;
    }

    if (GameLogic.isDraw(_board)) {
      _gameState = GameState.draw;
      _draws++;
      notifyListeners();
      return;
    }

    _currentPlayer = _currentPlayer == Player.x ? Player.o : Player.x;
    notifyListeners();

    if (_gameMode == GameMode.pvai && _currentPlayer == Player.o) {
      _performAiMove();
    }
  }

  Future<void> _performAiMove() async {
    _isAiThinking = true;
    notifyListeners();

    await Future.delayed(AppConstants.aiDelay);

    if (_gameState != GameState.playing) return;

    final move = _aiPlayer!.getMove(List.from(_board), Player.o);
    _isAiThinking = false;
    makeMove(move);
  }
}
