import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../presentation/bloc/matchmaking_cubit.dart';
import '../../../gameplay/presentation/pages/game_page.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MatchmakingCubit>(),
      child: const LobbyView(),
    );
  }
}

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  final TextEditingController _matchIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchmakingCubit, MatchmakingState>(
      listener: (context, state) {
        if (state is MatchmakingMatchStarted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const GamePage()),
          );
        } else if (state is MatchmakingMatchJoined) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const GamePage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: Center(
          child: BlocBuilder<MatchmakingCubit, MatchmakingState>(
            builder: (context, state) {
              if (state is MatchmakingLoading) {
                return const CircularProgressIndicator();
              }
              if (state is MatchmakingMatchCreated) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Waiting for opponent...'),
                    const SizedBox(height: 16),
                    SelectableText('Match ID: ${state.matchId}'),
                    const SizedBox(height: 8),
                    const Text('Share this ID with a friend'),
                  ],
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Using a random user ID for demo
                      context.read<MatchmakingCubit>().createMatch(
                        'user_${DateTime.now().millisecondsSinceEpoch}',
                      );
                    },
                    child: const Text('Create Match'),
                  ),
                  const SizedBox(height: 32),
                  const Text('OR'),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _matchIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Match ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_matchIdController.text.isNotEmpty) {
                        context.read<MatchmakingCubit>().joinMatch(
                          _matchIdController.text,
                          'user_${DateTime.now().millisecondsSinceEpoch}',
                        );
                      }
                    },
                    child: const Text('Join Match'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
