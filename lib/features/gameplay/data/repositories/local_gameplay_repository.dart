import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/i_gameplay_repository.dart';

class LocalGameplayRepository implements IGameplayRepository {
  final _gameStateController = BehaviorSubject<GameState>();
  Timer? _timer;

  // Mock data
  final String _targetWord = "FLUTTER";

  @override
  Stream<GameState> get gameStateStream => _gameStateController.stream;

  @override
  Future<void> startMatch(String matchId) async {
    final initialState = GameState(
      matchId: matchId,
      currentWord: _targetWord,
      timeLeft: 60,
      players: [
        const Player(id: 'local_player', username: 'You'),
        const Player(id: 'bot', username: 'Bot', score: 0),
      ],
    );

    _gameStateController.add(initialState);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = _gameStateController.value;
      if (currentState.timeLeft > 0 && !currentState.isGameOver) {
        _gameStateController.add(
          currentState.copyWith(timeLeft: currentState.timeLeft - 1),
        );
      } else {
        _timer?.cancel();
        _gameStateController.add(currentState.copyWith(isGameOver: true));
      }
    });
  }

  @override
  Future<void> submitGuess(
    String matchId,
    String playerId,
    String guess,
  ) async {
    final currentState = _gameStateController.value;
    if (currentState.isGameOver) return;

    if (guess.toUpperCase().trim() == _targetWord) {
      // Correct guess
      final updatedPlayers = currentState.players.map((p) {
        if (p.id == playerId) {
          return p.copyWith(score: p.score + 100);
        }
        return p;
      }).toList();

      _gameStateController.add(
        currentState.copyWith(
          players: updatedPlayers,
          isGameOver: true, // End game on correct guess for MVP
        ),
      );
      _timer?.cancel();
    }
  }

  @override
  Future<void> endMatch(String matchId) async {
    _timer?.cancel();
    final currentState = _gameStateController.value;
    _gameStateController.add(currentState.copyWith(isGameOver: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gameStateController.close();
  }
}
