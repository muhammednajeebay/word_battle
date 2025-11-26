import 'package:get_it/get_it.dart';
import '../../features/gameplay/data/repositories/local_gameplay_repository.dart';
import '../../features/gameplay/domain/repositories/i_gameplay_repository.dart';
import '../../features/gameplay/presentation/bloc/game_session_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Repositories
  getIt.registerLazySingleton<IGameplayRepository>(
    () => LocalGameplayRepository(),
  );

  // Cubits
  getIt.registerFactory(() => GameSessionCubit(getIt()));
}
