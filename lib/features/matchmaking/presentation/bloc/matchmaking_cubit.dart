import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/i_match_repository.dart';

// States
abstract class MatchmakingState extends Equatable {
  const MatchmakingState();
  @override
  List<Object?> get props => [];
}

class MatchmakingInitial extends MatchmakingState {}

class MatchmakingLoading extends MatchmakingState {}

class MatchmakingMatchCreated extends MatchmakingState {
  final String matchId;
  const MatchmakingMatchCreated(this.matchId);
  @override
  List<Object> get props => [matchId];
}

class MatchmakingMatchJoined extends MatchmakingState {
  final String matchId;
  const MatchmakingMatchJoined(this.matchId);
  @override
  List<Object> get props => [matchId];
}

class MatchmakingMatchStarted extends MatchmakingState {
  final Match match;
  const MatchmakingMatchStarted(this.match);
  @override
  List<Object> get props => [match];
}

class MatchmakingCubit extends Cubit<MatchmakingState> {
  final IMatchRepository _repository;
  StreamSubscription? _sub;

  MatchmakingCubit(this._repository) : super(MatchmakingInitial());

  Future<void> createMatch(String userId) async {
    emit(MatchmakingLoading());
    final matchId = await _repository.createMatch(userId);
    emit(MatchmakingMatchCreated(matchId));

    _sub?.cancel();
    _sub = _repository.watchMatch(matchId).listen((match) {
      if (match.status == 'started') {
        emit(MatchmakingMatchStarted(match));
      }
    });
  }

  Future<void> joinMatch(String matchId, String userId) async {
    emit(MatchmakingLoading());
    await _repository.joinMatch(matchId, userId);
    emit(MatchmakingMatchJoined(matchId));
    // In a real app, we'd also watch here or navigate immediately
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
