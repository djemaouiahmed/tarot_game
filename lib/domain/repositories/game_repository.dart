import '../entities/card.dart';
import '../entities/game_state.dart';

abstract class GameRepository {
  /// Initialise une nouvelle partie avec le nombre de joueurs spécifié
  Future initializeGame(
    int numberOfPlayers, {
    int initialCards,
    int startingLives,
  });

  /// Distribue les cartes pour un nouveau tour
  Future dealCards(GameState state);

  /// Enregistre le pari d'un joueur
  Future recordBid(GameState state, String playerId, int bid);

  /// Joue une carte
  Future playCard(GameState state, Card card);

  /// Calcule les scores à la fin d'un tour
  Future calculateScores(GameState state);

  /// Passe au tour suivant
  Future nextRound(GameState state);

  /// Passe à la manche suivante
  Future nextHand(GameState state);

  /// Vérifie si une carte peut être jouée (règles de suivi)
  bool canPlayCard(GameState state, Card card);

  /// Détermine le gagnant d'un pli
  int getTrickWinner(List<Card> trick, int leadPlayerIndex);

  /// Vide le pli après l'animation de fin de pli
  Future clearTrickAfterAnimation(GameState state);
}
