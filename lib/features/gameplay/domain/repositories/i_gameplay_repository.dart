import '../entities/game_state.dart';

abstract class IGameplayRepository {
  Future<void> startMatch(String matchId);
  Future<void> submitGuess(String matchId, String playerId, String guess);
  Future<void> endMatch(String matchId);
  Stream<GameState> get gameStateStream;
  void dispose();
}
