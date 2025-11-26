import '../entities/match.dart';

abstract class IMatchRepository {
  Future<String> createMatch(String userId);
  Future<void> joinMatch(String matchId, String userId);
  Stream<Match> watchMatch(String matchId);
}
