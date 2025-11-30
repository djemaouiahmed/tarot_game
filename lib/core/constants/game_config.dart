class GameConfig {
  final int numberOfPlayers;
  final int startingLives;
  final int initialCards; // Nombre de cartes au premier tour
  final bool teamsEnabled;
  final List<int>? teamAssignments; // Index du joueur -> numéro d'équipe
  final bool darkMode;
  final bool soundEnabled;

  const GameConfig({
    required this.numberOfPlayers,
    this.startingLives = 14, // Par défaut, commence au Roi (14)
    this.initialCards = 5, // Par défaut, 5 cartes au premier tour
    this.teamsEnabled = false,
    this.teamAssignments,
    this.darkMode = false,
    this.soundEnabled = true,
  });

  GameConfig copyWith({
    int? numberOfPlayers,
    int? startingLives,
    int? initialCards,
    bool? teamsEnabled,
    List<int>? teamAssignments,
    bool? darkMode,
    bool? soundEnabled,
  }) {
    return GameConfig(
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      startingLives: startingLives ?? this.startingLives,
      initialCards: initialCards ?? this.initialCards,
      teamsEnabled: teamsEnabled ?? this.teamsEnabled,
      teamAssignments: teamAssignments ?? this.teamAssignments,
      darkMode: darkMode ?? this.darkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  // Options de vies disponibles
  static const List<int> lifeOptions = [
    5, // Commence au 5
    6, // Commence au 6
    7, // Commence au 7
    8, // Commence au 8
    9, // Commence au 9
    10, // Commence au 10
    11, // Commence au Valet
    12, // Commence au Cavalier
    13, // Commence à la Dame
    14, // Commence au Roi (défaut)
  ];

  // Options de cartes initiales disponibles
  static const List<int> initialCardsOptions = [
    3, // 3 cartes au tour 1
    4, // 4 cartes au tour 1
    5, // 5 cartes au tour 1 (défaut)
    6, // 6 cartes au tour 1
    7, // 7 cartes au tour 1
  ];

  static String getLifeLabel(int lives) {
    switch (lives) {
      case 11:
        return '11 (Valet)';
      case 12:
        return '12 (Cavalier)';
      case 13:
        return '13 (Dame)';
      case 14:
        return '14 (Roi)';
      default:
        return lives.toString();
    }
  }

  static String getInitialCardsLabel(int cards) {
    return '$cards cartes';
  }
}
