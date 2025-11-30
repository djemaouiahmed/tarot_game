import '../entities/card.dart';
import '../entities/game_state.dart';
import '../repositories/game_repository.dart';

class PlayCard {
  final GameRepository repository;

  PlayCard(this.repository);

  Future call(GameState state, Card card) async {
    return await repository.playCard(state, card);
  }
}