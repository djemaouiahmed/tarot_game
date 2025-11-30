import '../entities/game_state.dart';
import '../repositories/game_repository.dart';

class ClearTrick {
  final GameRepository repository;

  ClearTrick(this.repository);

  Future<GameState> call(GameState state) async {
    return await repository.clearTrickAfterAnimation(state);
  }
}
