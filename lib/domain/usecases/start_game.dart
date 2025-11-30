import '../repositories/game_repository.dart';

class StartGame {
  final GameRepository repository;

  StartGame(this.repository);

  Future call(
    int numberOfPlayers, {
    int initialCards = 5,
    int startingLives = 14,
  }) async {
    return await repository.initializeGame(
      numberOfPlayers,
      initialCards: initialCards,
      startingLives: startingLives,
    );
  }
}
