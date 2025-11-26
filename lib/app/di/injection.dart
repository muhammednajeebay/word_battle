import 'package:get_it/get_it.dart';
import '../../features/gameplay/data/repositories/firestore_gameplay_repository.dart';
import '../../features/gameplay/domain/repositories/i_gameplay_repository.dart';
import '../../features/gameplay/presentation/bloc/game_session_cubit.dart';
import '../../features/matchmaking/data/repositories/firestore_match_repository.dart';
import '../../features/matchmaking/domain/repositories/i_match_repository.dart';
import '../../features/matchmaking/presentation/bloc/matchmaking_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Repositories
  getIt.registerLazySingleton<IGameplayRepository>(
    () => FirestoreGameplayRepository(),
  );
  getIt.registerLazySingleton<IMatchRepository>(
    () => FirestoreMatchRepository(),
  );

  // Cubits
  getIt.registerFactory(() => GameSessionCubit(getIt()));
  getIt.registerFactory(() => MatchmakingCubit(getIt()));
}
