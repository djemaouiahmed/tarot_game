import 'package:tarot_africain/domain/entities/card.dart';

// Type de joueur: humain ou bot
enum PlayerType { human, bot }

// Représente un joueur avec son état complet
class Player {
  final String id; // Identifiant unique
  final String name; // Nom affiché
  final PlayerType type; // Humain ou bot
  final List<Card> hand; // Main actuelle de cartes
  final List<Card>
  ordinaryCards; // Paquet de cartes ordinaires gagnées (face visible)
  int score; // Score actuel (vies restantes)
  int currentBid; // Annonce pour le tour en cours
  int tricksWon; // Nombre de plis gagnés dans le tour

  Player({
    required this.id,
    required this.name,
    required this.type,
    this.hand = const <Card>[],
    this.ordinaryCards = const <Card>[],
    this.score = 0,
    this.currentBid = 0,
    this.tricksWon = 0,
  });

  // Crée une copie du joueur avec certains champs modifiés
  Player copyWith({
    List<Card>? hand,
    List<Card>? ordinaryCards,
    int? score,
    int? currentBid,
    int? tricksWon,
  }) {
    return Player(
      id: id,
      name: name,
      type: type,
      hand: hand ?? this.hand,
      ordinaryCards: ordinaryCards ?? this.ordinaryCards,
      score: score ?? this.score,
      currentBid: currentBid ?? this.currentBid,
      tricksWon: tricksWon ?? this.tricksWon,
    );
  }
}
