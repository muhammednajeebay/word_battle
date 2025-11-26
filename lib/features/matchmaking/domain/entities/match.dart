import 'package:equatable/equatable.dart';

class Match extends Equatable {
  final String id;
  final String hostId;
  final String? opponentId;
  final String status; // 'waiting', 'started', 'finished'

  const Match({
    required this.id,
    required this.hostId,
    this.opponentId,
    required this.status,
  });

  @override
  List<Object?> get props => [id, hostId, opponentId, status];
}
