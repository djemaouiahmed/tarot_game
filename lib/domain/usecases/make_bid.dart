import '../entities/game_state.dart';
import '../repositories/game_repository.dart';

class MakeBid {
  final GameRepository repository;

  MakeBid(this.repository);

  Future call(GameState state, String playerId, int bid) async {
    return await repository.recordBid(state, playerId, bid);
  }
}