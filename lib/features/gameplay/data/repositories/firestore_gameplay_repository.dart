import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_state.dart';

import '../../domain/repositories/i_gameplay_repository.dart';

class FirestoreGameplayRepository implements IGameplayRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<GameState> get gameStateStream =>
      throw UnimplementedError("Use watchGameState(matchId) instead");

  Stream<GameState> watchGameState(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots().map((doc) {
      final data = doc.data()!;
      // This is a simplified mapping. In a real app, you'd parse subcollections or a 'state' field.
      // For MVP, we assume state is stored on the match doc or a single subdoc.
      return GameState(
        matchId: doc.id,
        currentWord: data['currentWord'] ?? '???',
        timeLeft: data['timeLeft'] ?? 0,
        players: [], // You would parse players from a subcollection or field
        isGameOver: data['status'] == 'finished',
      );
    });
  }

  @override
  Future<void> startMatch(String matchId) async {
    // In Firebase, match start is usually handled by Cloud Functions or Matchmaking
    // But we can set initial state here if needed
  }

  @override
  Future<void> submitGuess(
    String matchId,
    String playerId,
    String guess,
  ) async {
    // Get the current match to validate the guess
    final matchDoc = await _firestore.collection('matches').doc(matchId).get();
    final matchData = matchDoc.data();

    if (matchData == null) return;

    final currentWord = matchData['currentWord'] as String?;
    final isCorrect = guess.toUpperCase().trim() == currentWord?.toUpperCase();

    // Write the guess to a subcollection
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('guesses')
        .add({
          'playerId': playerId,
          'guess': guess,
          'correct': isCorrect,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // If correct, update match status
    if (isCorrect) {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'finished',
        'winnerId': playerId,
      });
    }
  }

  @override
  Future<void> endMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': 'finished',
    });
  }

  @override
  void dispose() {}
}
