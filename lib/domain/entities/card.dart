// Couleurs possibles des cartes
enum CardSuit {
  clubs, // Trèfle
  spades, // Pique
  diamonds, // Carreau
  hearts, // Coeur
  trump, // Atout
  excuse, // Excuse (carte spéciale)
}

// Rangs possibles des cartes
enum CardRank {
  // Ordinary cards (14)
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  knight,
  queen,
  king,
  ace,

  // Trumps (21) - You must define ALL of them for the loop to work
  trump1,
  trump2,
  trump3,
  trump4,
  trump5,
  trump6,
  trump7,
  trump8,
  trump9,
  trump10,
  trump11,
  trump12,
  trump13,
  trump14,
  trump15,
  trump16,
  trump17,
  trump18,
  trump19,
  trump20,
  trump21,

  // Excuse (1)
  excuse,
}

// Représente une carte de tarot avec toutes ses propriétés
class Card {
  final CardSuit suit; // Couleur de la carte
  final CardRank rank; // Rang de la carte
  final int value; // Valeur (atouts: 1-21, excuse: 0 ou 22)
  final int? excuseValue; // Valeur choisie pour l'excuse (0 ou 22)

  const Card({
    required this.suit,
    required this.rank,
    required this.value,
    this.excuseValue,
  });

  // Vérifie si la carte est un atout
  bool get isTrump => suit == CardSuit.trump;

  // Vérifie si la carte est l'excuse
  bool get isExcuse => suit == CardSuit.excuse;

  // Valeur effective de l'excuse selon le choix du joueur
  int get effectiveValue =>
      isExcuse && excuseValue != null ? excuseValue! : value;

  // Crée une copie de la carte avec certains champs modifiés
  Card copyWith({
    CardSuit? suit,
    CardRank? rank,
    int? value,
    int? excuseValue,
  }) {
    return Card(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      value: value ?? this.value,
      excuseValue: excuseValue ?? this.excuseValue,
    );
  }

  // Compare deux cartes selon les règles du Tarot Africain
  // Retourne: -1 si this < other, 0 si égalité, 1 si this > other
  int compareTo(Card other) {
    // L'excuse perd toujours
    if (isExcuse) return -1;
    if (other.isExcuse) return 1;

    // Comparaison entre atouts
    if (isTrump && other.isTrump) {
      return value.compareTo(other.value);
    }

    // Un atout bat toujours une carte ordinaire
    if (isTrump) return 1;
    if (other.isTrump) return -1;

    // Même couleur: comparer les valeurs
    if (suit == other.suit) {
      return value.compareTo(other.value);
    }

    // Couleurs différentes: pas de comparaison possible
    return 0;
  }

  @override
  String toString() => '$rank of $suit';
}
