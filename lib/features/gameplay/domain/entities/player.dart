import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String username;
  final int score;

  const Player({required this.id, required this.username, this.score = 0});

  Player copyWith({String? id, String? username, int? score}) {
    return Player(
      id: id ?? this.id,
      username: username ?? this.username,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [id, username, score];
}
