import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/i_gameplay_repository.dart';

// States
abstract class GameSessionState extends Equatable {
  const GameSessionState();
  @override
  List<Object> get props => [];
}

class GameSessionInitial extends GameSessionState {}

class GameSessionLoading extends GameSessionState {}

class GameSessionActive extends GameSessionState {
  final GameState gameState;
  const GameSessionActive(this.gameState);
  @override
  List<Object> get props => [gameState];
}

class GameSessionGameOver extends GameSessionState {
  final GameState gameState;
  const GameSessionGameOver(this.gameState);
  @override
  List<Object> get props => [gameState];
}

// Cubit
class GameSessionCubit extends Cubit<GameSessionState> {
  final IGameplayRepository _repository;
  StreamSubscription? _subscription;

  GameSessionCubit(this._repository) : super(GameSessionInitial());

  Future<void> startGame() async {
    emit(GameSessionLoading());
    await _repository.startMatch('local_match');

    _subscription?.cancel();
    _subscription = _repository.gameStateStream.listen((state) {
      if (state.isGameOver) {
        emit(GameSessionGameOver(state));
      } else {
        emit(GameSessionActive(state));
      }
    });
  }

  Future<void> submitGuess(String guess) async {
    await _repository.submitGuess('local_match', 'local_player', guess);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
