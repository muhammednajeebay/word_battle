import 'package:equatable/equatable.dart';
import 'player.dart';

class GameState extends Equatable {
  final String matchId;
  final String currentWord;
  final int timeLeft;
  final List<Player> players;
  final bool isGameOver;

  const GameState({
    required this.matchId,
    required this.currentWord,
    required this.timeLeft,
    required this.players,
    this.isGameOver = false,
  });

  GameState copyWith({
    String? matchId,
    String? currentWord,
    int? timeLeft,
    List<Player>? players,
    bool? isGameOver,
  }) {
    return GameState(
      matchId: matchId ?? this.matchId,
      currentWord: currentWord ?? this.currentWord,
      timeLeft: timeLeft ?? this.timeLeft,
      players: players ?? this.players,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  @override
  List<Object?> get props => [
    matchId,
    currentWord,
    timeLeft,
    players,
    isGameOver,
  ];
}
