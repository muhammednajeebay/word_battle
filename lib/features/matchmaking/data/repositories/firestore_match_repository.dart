import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/i_match_repository.dart';

class FirestoreMatchRepository implements IMatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createMatch(String userId) async {
    // Generate a random word (in production, use a word list)
    final words = ['FLUTTER', 'DART', 'FIREBASE', 'WIDGET', 'STATE', 'BUILD'];
    final randomWord =
        words[DateTime.now().millisecondsSinceEpoch % words.length];

    final docRef = await _firestore.collection('matches').add({
      'hostId': userId,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'currentWord': randomWord,
      'timeLeft': 60,
    });
    return docRef.id;
  }

  @override
  Future<void> joinMatch(String matchId, String userId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'opponentId': userId,
      'status': 'started',
    });
  }

  @override
  Stream<Match> watchMatch(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots().map((doc) {
      final data = doc.data()!;
      return Match(
        id: doc.id,
        hostId: data['hostId'],
        opponentId: data['opponentId'],
        status: data['status'],
      );
    });
  }
}
