class GameConstants {
  // Animation durations
  static const int cardAnimationDuration = 600;
  static const int trickClearDelay = 2000;
  static const int glowAnimationDuration = 1500;

  // Card dimensions
  static const double defaultCardWidth = 100.0;
  static const double defaultCardHeight = 220.0;
  static const double tableCardWidth = 80.0;
  static const double tableCardHeight = 120.0;
  static const double opponentCardWidth = 70.0;
  static const double opponentCardHeight = 105.0;

  // Table dimensions
  static const double tableWidth = 300.0;
  static const double tableHeight = 300.0;

  // Spacing
  static const double cardSpacing = 25.0;
  static const double cardVerticalOffset = 10.0;

  // Game rules
  static const int totalRounds = 5;
  static const int startingLives = 14;
  static const int minPlayers = 3;
  static const int maxPlayers = 4;

  // Bot difficulty weights
  static const double easyBidAccuracy = 0.5;
  static const double mediumBidAccuracy = 0.7;
  static const double hardBidAccuracy = 0.9;
}
