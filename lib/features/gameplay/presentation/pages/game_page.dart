import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../bloc/game_session_cubit.dart';
import '../widgets/drawing_canvas.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GameSessionCubit>()..startGame(),
      child: const GameView(),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final TextEditingController _guessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Battle Arena'),
        actions: [
          BlocBuilder<GameSessionCubit, GameSessionState>(
            builder: (context, state) {
              if (state is GameSessionActive) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Time: ${state.gameState.timeLeft}s'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scoreboard
          BlocBuilder<GameSessionCubit, GameSessionState>(
            builder: (context, state) {
              int score = 0;
              if (state is GameSessionActive) {
                score = state.gameState.players
                    .firstWhere((p) => p.id == 'local_player')
                    .score;
              } else if (state is GameSessionGameOver) {
                score = state.gameState.players
                    .firstWhere((p) => p.id == 'local_player')
                    .score;
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Score: $score',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            },
          ),

          // Canvas Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: const DrawingCanvas(),
            ),
          ),

          // Guess Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your guess...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _submitGuess(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _submitGuess(context),
                  child: const Text('Guess'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitGuess(BuildContext context) {
    final guess = _guessController.text;
    if (guess.isNotEmpty) {
      context.read<GameSessionCubit>().submitGuess(guess);
      _guessController.clear();
    }
  }
}
