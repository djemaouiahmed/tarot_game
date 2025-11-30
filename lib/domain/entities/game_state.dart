import 'package:tarot_africain/domain/entities/player.dart';
import 'card.dart';

// Phases possibles d'une partie de Tarot Africain
enum GamePhase {
  setup, // Configuration initiale
  handReview, // Revue des cartes distribuées
  bidding, // Phase d'annonces
  playing, // Phase de jeu
  scoring, // Calcul des scores
  gameOver, // Partie terminée
}

// Vérifie si c'est le tour 5 (règle spéciale: on voit les mains des autres)
bool isRound5BlindRound(int currentRound) => currentRound == 5;

// État global du jeu contenant toutes les informations de la partie
class GameState {
  final List<Player> players; // Liste de tous les joueurs
  final int dealerIndex; // Index du donneur
  final int currentPlayerIndex; // Index du joueur actuel
  final GamePhase phase; // Phase actuelle de la partie
  final int currentRound; // Tour actuel (1-5)
  final int initialCards; // Nombre de cartes au premier tour
  final List<Card> currentTrick; // Pli en cours
  final List<int> bids; // Annonces des joueurs
  final bool isLastCardBlind; // Tour 5: carte sur le front sans la voir
  final bool isAnimating; // Animation en cours
  final Card? lastPlayedCard; // Dernière carte jouée (pour animation)
  final int? lastPlayerIndex; // Joueur ayant joué la dernière carte

  GameState({
    required this.players,
    this.dealerIndex = 0,
    this.currentPlayerIndex = 0,
    this.phase = GamePhase.setup,
    this.currentRound = 1,
    this.initialCards = 5,
    this.currentTrick = const <Card>[],
    this.bids = const <int>[],
    this.isLastCardBlind = false,
    this.isAnimating = false,
    this.lastPlayedCard,
    this.lastPlayerIndex,
  });

  // Nombre de cartes distribuées par tour (dégressif à partir de initialCards)
  int get cardsPerRound => (initialCards + 1) - currentRound;

  // Vérifie si un joueur a perdu (score <= 0)
  bool get isGameOver => players.any((p) => p.score <= 0);

  // Joueur dont c'est le tour
  Player get currentPlayer => players[currentPlayerIndex];

  // Joueur avec le meilleur score
  Player get winner => players.reduce((a, b) => a.score > b.score ? a : b);
}
