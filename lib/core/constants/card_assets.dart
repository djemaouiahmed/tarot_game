import 'package:flutter/material.dart' hide Card; // <--- Added 'hide Card' to fix the conflict
import '../../domain/entities/card.dart';

class CardAssets {
  // Base paths
  static const String _basePath = 'assets/images/cards';
  static const String _clubsPath = '$_basePath/clubs';
  static const String _spadesPath = '$_basePath/spades';
  static const String _diamondsPath = '$_basePath/diamonds';
  static const String _heartsPath = '$_basePath/hearts';
  static const String _trumpsPath = '$_basePath/trumps';

  // Special cards
  static const String excuse = '$_basePath/excuse.png';
  // Fallback card back image — use an existing UI asset if a dedicated back is not provided
  // Prefer a dedicated card back image; fallback to UI logo if missing at runtime
  static const String cardBack = '$_basePath/card_back.png';

  // Main method to get the correct image path
  static String getCardPath(Card card) {
    if (card.isExcuse) {
      return excuse;
    }

    if (card.isTrump) {
      // Trump files format: CaJ-TaroTv1-1AT.png, CaJ-TaroTv1-21AT.png
      return '$_trumpsPath/CaJ-TaroTv1-${card.value}AT.png';
    }

    final suitPath = _getSuitPath(card.suit);
    final suitLetter = _getSuitLetter(card.suit);
    final rankCode = _getRankCode(card.rank);

    // Standard card format: CaJ-TaroTv1-[Rank][Suit].png
    // Example: CaJ-TaroTv1-RT.png (King of Clubs)
    return '$suitPath/CaJ-TaroTv1-$rankCode$suitLetter.png';
  }

  static String _getSuitPath(CardSuit suit) {
    switch (suit) {
      case CardSuit.clubs:
        return _clubsPath;
      case CardSuit.spades:
        return _spadesPath;
      case CardSuit.diamonds:
        return _diamondsPath;
      case CardSuit.hearts:
        return _heartsPath;
      default:
        return _basePath;
    }
  }

  // Maps CardSuit to the letter used in your filenames
  static String _getSuitLetter(CardSuit suit) {
    switch (suit) {
      case CardSuit.clubs:
        return 'T'; // Trèfle
      case CardSuit.spades:
        return 'P'; // Pique
      case CardSuit.diamonds:
        return 'K'; // Carreau
      case CardSuit.hearts:
        return 'C'; // Cœur
      default:
        return '';
    }
  }

  // Maps CardRank to the code used in your filenames
  static String _getRankCode(CardRank rank) {
    switch (rank) {
      case CardRank.ace:
        return 'A';
      case CardRank.king:
        return 'R'; // Roi
      case CardRank.queen:
        return 'D'; // Dame
      case CardRank.knight:
        return 'C'; // Cavalier
      case CardRank.jack:
        return 'V'; // Valet
      case CardRank.ten:
        return '10';
      case CardRank.nine:
        return '9';
      case CardRank.eight:
        return '8';
      case CardRank.seven:
        return '7';
      case CardRank.six:
        return '6';
      case CardRank.five:
        return '5';
      case CardRank.four:
        return '4';
      case CardRank.three:
        return '3';
      case CardRank.two:
        return '2';
      default:
        return '';
    }
  }

  // Preloader to cache images for performance
  static Future<void> preloadAllCards(BuildContext context) async {
    final List<String> allCardPaths = [];

    // Add standard cards
    for (final suit in [CardSuit.clubs, CardSuit.spades, CardSuit.diamonds, CardSuit.hearts]) {
      for (final rank in CardRank.values) {
        // Skip trumps and excuse in this loop (handled separately or logic specific to your enums)
        // Assuming trump1 is the start of trumps in your enum order
        if (rank.index >= CardRank.trump1.index) continue;

        // Create a dummy card to generate the path
        final card = Card(suit: suit, rank: rank, value: 0);
        allCardPaths.add(getCardPath(card));
      }
    }

    // Add trumps
    for (int i = 1; i <= 21; i++) {
      allCardPaths.add('$_trumpsPath/CaJ-TaroTv1-${i}AT.png');
    }

    // Add excuse and back
    allCardPaths.add(excuse);
    allCardPaths.add(cardBack);

    // Precache
    for (final path in allCardPaths) {
      await precacheImage(AssetImage(path), context);
    }
  }
}