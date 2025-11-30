import 'dart:math';
import '../entities/card.dart';
import '../entities/game_state.dart';
import '../entities/player.dart';
import '../repositories/game_repository.dart';
import '../entities/bot_difficulty.dart';

class GetBotMove {
  final GameRepository repository;
  final Random _random = Random();

  GetBotMove(this.repository);

  Future call(GameState state, BotDifficulty difficulty) async {
    if (state.phase == GamePhase.bidding) {
      return await _calculateBotBid(state, difficulty);
    } else {
      return await _calculateBotCard(state, difficulty);
    }
  }

  // ========== GESTION DES PARIS ==========

  Future _calculateBotBid(GameState state, BotDifficulty difficulty) async {
    switch (difficulty) {
      case BotDifficulty.easy:
        return _randomBid(state);
      case BotDifficulty.medium:
        return _strategicBid(state);
      case BotDifficulty.hard:
        return _advancedBid(state);
    }
  }

  int _randomBid(GameState state) {
    final maxBid = state.cardsPerRound;

    // Trouver tous les paris valides
    final validBids = <int>[];
    for (int i = 0; i <= maxBid; i++) {
      if (_isValidBid(state, i)) {
        validBids.add(i);
      }
    }

    // Si aucun pari valide, retourner 0 par défaut
    if (validBids.isEmpty) {
      return 0;
    }

    return validBids[_random.nextInt(validBids.length)];
  }

  int _strategicBid(GameState state) {
    final hand = state.currentPlayer.hand;

    // Analyze hand in detail
    final trumps = hand.where((c) => c.isTrump).toList();
    final hasExcuse = hand.any((c) => c.isExcuse);

    // Categorize trumps by strength
    int veryStrongTrumps = trumps.where((c) => c.value >= 18).length; // 18-21
    int strongTrumps = trumps
        .where((c) => c.value >= 14 && c.value < 18)
        .length; // 14-17
    int mediumTrumps = trumps
        .where((c) => c.value >= 10 && c.value < 14)
        .length; // 10-13
    int weakTrumps = trumps.where((c) => c.value < 10).length; // 1-9

    // Calculate hand strength score
    double handStrength =
        veryStrongTrumps * 1.0 + // Almost certain to win
        strongTrumps * 0.7 + // Good chance of winning
        mediumTrumps * 0.4 + // Medium chance
        weakTrumps * 0.1; // Low chance

    // Excuse counts as 0.5 trick (can win or lose as needed)
    if (hasExcuse) {
      handStrength += 0.5;
    }

    // Adjust based on number of players (more competition = harder to win)
    final competitionFactor =
        state.players.length / 4.0; // 0.75 for 3 players, 1.0 for 4
    handStrength *= (1.0 - (competitionFactor - 1.0) * 0.2);

    int estimatedTricks = handStrength.round();

    // Strategy based on position: last player can be more aggressive
    final isLastPlayer = state.bids.length == state.players.length - 1;
    if (isLastPlayer) {
      final totalBids = state.bids.fold<int>(0, (sum, bid) => sum + bid);
      final forbidden = state.cardsPerRound - totalBids;

      // If our estimate is forbidden, choose strategically
      if (estimatedTricks == forbidden) {
        // If we have strong hand, bid higher
        if (handStrength > forbidden) {
          estimatedTricks = forbidden + 1;
        } else {
          estimatedTricks = forbidden - 1;
        }
      }
    }

    // Verify bid is valid
    if (_isValidBid(state, estimatedTricks)) {
      return estimatedTricks;
    }

    // Essayer les paris voisins
    for (int i = 1; i <= state.cardsPerRound; i++) {
      if (estimatedTricks + i <= state.cardsPerRound &&
          _isValidBid(state, estimatedTricks + i)) {
        return estimatedTricks + i;
      }
      if (estimatedTricks - i >= 0 && _isValidBid(state, estimatedTricks - i)) {
        return estimatedTricks - i;
      }
    }

    return _findAnyValidBid(state);
  }

  int _advancedBid(GameState state) {
    final hand = state.currentPlayer.hand;
    final trumps = hand.where((c) => c.isTrump).toList();
    final hasExcuse = hand.any((c) => c.isExcuse);

    // ULTRA-precise hand analysis
    int veryStrongTrumps = trumps
        .where((c) => c.value >= 19)
        .length; // 19-21 (Boss)
    int strongTrumps = trumps
        .where((c) => c.value >= 15 && c.value < 19)
        .length; // 15-18
    int mediumTrumps = trumps
        .where((c) => c.value >= 11 && c.value < 15)
        .length; // 11-14
    int weakTrumps = trumps
        .where((c) => c.value >= 7 && c.value < 11)
        .length; // 7-10
    int veryWeakTrumps = trumps.where((c) => c.value < 7).length; // 1-6

    // Ultra-weighted strength score (hard mode = more precise)
    double handStrength =
        veryStrongTrumps *
            0.95 + // 95% chance to win (in case opponent has Excuse 22)
        strongTrumps * 0.75 + // 75% chance to win
        mediumTrumps * 0.45 + // 45% chance to win
        weakTrumps * 0.18 + // 18% chance to win
        veryWeakTrumps * 0.03; // 3% chance to win

    // Excuse is a strategic ultra-powerful joker
    if (hasExcuse) {
      handStrength +=
          0.65; // Slightly more than Medium due to better utilization
    }

    // Round factor: more precise at end of game
    final roundFactor = (6 - state.currentRound) / 5.0;
    handStrength *= (0.85 + roundFactor * 0.15); // More conservative

    // Analyze already made bids and opponent strategy
    final totalBids = state.bids.fold<int>(0, (sum, bid) => sum + bid);
    final averageBid = state.bids.isEmpty ? 0.0 : totalBids / state.bids.length;

    // Competition analysis (more sophisticated)
    final competitionLevel = state.bids.isEmpty
        ? 0.5
        : averageBid / state.cardsPerRound;

    if (competitionLevel > 0.6) {
      // VERY strong competition: be very cautious
      handStrength *= 0.85;
    } else if (competitionLevel > 0.4) {
      // Strong competition: be cautious
      handStrength *= 0.92;
    } else if (competitionLevel < 0.25) {
      // Low competition: be aggressive
      handStrength *= 1.08;
    }

    // Analyze player position (very important!)
    final playerPosition = state.bids.length + 1;
    final totalPlayers = state.players.length;

    if (playerPosition == 1) {
      // First to bid: slightly more conservative
      handStrength *= 0.95;
    } else if (playerPosition == totalPlayers - 1) {
      // Second to last: analyze what remains
      final remaining = state.cardsPerRound - totalBids;
      if (remaining <= 1) {
        // Little margin: be cautious
        handStrength *= 0.9;
      }
    }

    int estimatedTricks = handStrength.round().clamp(0, state.cardsPerRound);

    // Last player strategy (ULTRA sophisticated)
    final isLastPlayer = state.bids.length == state.players.length - 1;
    if (isLastPlayer) {
      final forbidden = state.cardsPerRound - totalBids;

      if (estimatedTricks == forbidden) {
        // Analyze options with maximum precision
        final canBidHigher = forbidden < state.cardsPerRound;
        final canBidLower = forbidden > 0;

        if (canBidHigher && canBidLower) {
          // Choose based on REAL strength vs forbidden bid
          final confidenceMargin = handStrength - forbidden;

          if (confidenceMargin > 0.4) {
            // Very confident: bid higher
            estimatedTricks = forbidden + 1;
          } else if (confidenceMargin < -0.4) {
            // Not confident: bid lower
            estimatedTricks = forbidden - 1;
          } else {
            // Uncertain: analyze boss trumps
            if (veryStrongTrumps >= 2 || (veryStrongTrumps >= 1 && hasExcuse)) {
              estimatedTricks = forbidden + 1;
            } else {
              estimatedTricks = forbidden - 1;
            }
          }
        } else if (canBidHigher) {
          estimatedTricks = forbidden + 1;
        } else if (canBidLower) {
          estimatedTricks = forbidden - 1;
        }
      }
    }

    // Verify and find valid bid nearby
    for (int delta = 0; delta <= state.cardsPerRound; delta++) {
      final tryExact = estimatedTricks;
      final tryHigher = estimatedTricks + delta;
      final tryLower = estimatedTricks - delta;

      if (delta == 0 && _isValidBid(state, tryExact)) {
        return tryExact;
      }
      if (tryHigher <= state.cardsPerRound && _isValidBid(state, tryHigher)) {
        return tryHigher;
      }
      if (tryLower >= 0 && _isValidBid(state, tryLower)) {
        return tryLower;
      }
    }

    return _findAnyValidBid(state);
  }

  int _findAnyValidBid(GameState state) {
    // Find any valid bid
    for (int i = 0; i <= state.cardsPerRound; i++) {
      if (_isValidBid(state, i)) {
        return i;
      }
    }
    // Last resort (should never happen)
    return 0;
  }

  bool _isValidBid(GameState state, int bid) {
    // Verify bid is in valid range
    if (bid < 0 || bid > state.cardsPerRound) {
      return false;
    }

    // Calculate total sum if this bid is made
    int totalBids = bid;
    for (final b in state.bids) {
      totalBids += b;
    }

    // Check if this is the last player
    final isLastPlayer = state.bids.length == state.players.length - 1;

    // Last player cannot make a bid that equals or exceeds cardsPerRound
    if (isLastPlayer && totalBids >= state.cardsPerRound) {
      return false;
    }

    return true;
  }

  // ========== GESTION DES CARTES À JOUER ==========

  Future _calculateBotCard(GameState state, BotDifficulty difficulty) async {
    switch (difficulty) {
      case BotDifficulty.easy:
        return _randomCard(state);
      case BotDifficulty.medium:
        return _strategicCard(state);
      case BotDifficulty.hard:
        return _advancedCard(state);
    }
  }

  Card _randomCard(GameState state) {
    final validCards = state.currentPlayer.hand
        .where((card) => repository.canPlayCard(state, card))
        .toList();

    if (validCards.isEmpty) {
      return state.currentPlayer.hand.first;
    }

    final selectedCard = validCards[_random.nextInt(validCards.length)];

    // Si c'est l'Excuse, choisir intelligemment même en mode Easy
    if (selectedCard.isExcuse) {
      final player = state.currentPlayer;
      final tricksNeeded = player.currentBid - player.tricksWon;

      // Logique simple: si besoin de gagner, 70% de chance de jouer 22
      // Sinon, 70% de chance de jouer 0
      final excuseValue = tricksNeeded > 0
          ? (_random.nextDouble() < 0.7 ? 22 : 0)
          : (_random.nextDouble() < 0.7 ? 0 : 22);

      print(
        '🤖 Bot EASY joue Excuse - Besoin: $tricksNeeded plis -> valeur: $excuseValue',
      );
      return selectedCard.copyWith(excuseValue: excuseValue);
    }

    return selectedCard;
  }

  Card _strategicCard(GameState state) {
    final validCards = _getValidCards(state);
    if (validCards.isEmpty) return state.currentPlayer.hand.first;

    final player = state.currentPlayer;
    final tricksNeeded = player.currentBid - player.tricksWon;
    final tricksRemaining = _calculateTricksRemaining(state, player);

    // Analyze current trick
    final isFirstCard = state.currentTrick.isEmpty;
    Card? currentWinner;
    int? winnerValue;

    if (!isFirstCard) {
      currentWinner = _getCurrentWinner(state.currentTrick);
      winnerValue = currentWinner.isExcuse
          ? currentWinner.excuseValue ?? 0
          : currentWinner.value;
    }

    Card selectedCard;

    if (tricksNeeded > 0) {
      // Need to win tricks
      if (isFirstCard) {
        // Playing first: strategy based on remaining tricks
        if (tricksNeeded >= tricksRemaining) {
          // Urgent: play strong card to try winning
          validCards.sort((a, b) => b.value.compareTo(a.value));
          selectedCard = validCards.first;
        } else {
          // Not urgent: play medium card to test
          final middleIndex = validCards.length ~/ 2;
          validCards.sort((a, b) => b.value.compareTo(a.value));
          selectedCard =
              validCards[middleIndex.clamp(0, validCards.length - 1)];
        }
      } else {
        // Jouer après d'autres: essayer de gagner avec la plus petite carte possible
        final canWinCards = validCards.where((c) {
          if (c.isExcuse)
            return true; // L'Excuse peut toujours gagner avec valeur 22
          if (!c.isTrump)
            return false; // Les cartes ordinaires ne battent jamais les atouts
          return c.value > (winnerValue ?? 0);
        }).toList();

        if (canWinCards.isNotEmpty) {
          // Play smallest winning card (save big ones)
          // IMPORTANT: Excuse with value 22 is sorted as value 22
          canWinCards.sort((a, b) {
            final aVal = a.isExcuse ? 22 : a.value;
            final bVal = b.isExcuse ? 22 : b.value;
            return aVal.compareTo(bVal);
          });
          selectedCard = canWinCards.first;
        } else {
          // Cannot win: play smallest card to minimize losses
          validCards.sort((a, b) => a.value.compareTo(b.value));
          selectedCard = validCards.first;
        }
      }
    } else if (tricksNeeded == 0) {
      // Objectif atteint: essayer de perdre tous les plis restants
      if (isFirstCard) {
        // Jouer la plus petite carte possible
        validCards.sort((a, b) => a.value.compareTo(b.value));
        selectedCard = validCards.first;
      } else {
        // Jouer une carte qui ne gagne pas, la plus petite possible
        final losingCards = validCards.where((c) {
          if (c.isExcuse) return false; // Éviter l'Excuse qui peut gagner
          if (!c.isTrump)
            return true; // Les cartes ordinaires perdent toujours face aux atouts
          return c.value < (winnerValue ?? 0);
        }).toList();

        if (losingCards.isNotEmpty) {
          losingCards.sort((a, b) => a.value.compareTo(b.value));
          selectedCard = losingCards.first;
        } else {
          // Forced to play winning card: play smallest
          validCards.sort((a, b) => a.value.compareTo(b.value));
          selectedCard = validCards.first;
        }
      }
    } else {
      // tricksNeeded < 0: already won too many tricks
      // Strategy: lose all remaining tricks
      validCards.sort((a, b) => a.value.compareTo(b.value));
      // Avoid Excuse if possible
      final nonExcuseCards = validCards.where((c) => !c.isExcuse).toList();
      if (nonExcuseCards.isNotEmpty) {
        selectedCard = nonExcuseCards.first;
      } else {
        selectedCard = validCards.first;
      }
    }

    // Handle Excuse card
    if (selectedCard.isExcuse) {
      final excuseValue = _chooseExcuseValue(
        state,
        tricksNeeded,
        tricksRemaining,
      );
      return selectedCard.copyWith(excuseValue: excuseValue);
    }

    return selectedCard;
  }

  Card _advancedCard(GameState state) {
    final validCards = _getValidCards(state);
    if (validCards.isEmpty) return state.currentPlayer.hand.first;

    final player = state.currentPlayer;
    final tricksNeeded = player.currentBid - player.tricksWon;
    final tricksRemaining = _calculateTricksRemaining(state, player);

    // Card counting: analyze played cards
    final playedCards = _getPlayedCards(state);
    final remainingHighTrumps = _countRemainingHighTrumps(
      playedCards,
      validCards,
    );

    final isFirstCard = state.currentTrick.isEmpty;
    Card? currentWinner;
    int? winnerValue;

    if (!isFirstCard) {
      currentWinner = _getCurrentWinner(state.currentTrick);
      winnerValue = currentWinner.isExcuse
          ? currentWinner.excuseValue ?? 0
          : currentWinner.value;
    }

    Card selectedCard;

    if (tricksNeeded > 0) {
      // Need to win: ultra-aggressive and intelligent strategy
      if (isFirstCard) {
        // Playing first
        if (tricksNeeded >= tricksRemaining) {
          // URGENT: play very strong card
          final strongCards = validCards
              .where((c) => c.isTrump && c.value >= 15)
              .toList();
          if (strongCards.isNotEmpty) {
            strongCards.sort((a, b) => b.value.compareTo(a.value));
            selectedCard = strongCards.first;
          } else {
            validCards.sort((a, b) => b.value.compareTo(a.value));
            selectedCard = validCards.first;
          }
        } else if (tricksNeeded == tricksRemaining) {
          // Critical: play strong card but not the best (save ace for later)
          validCards.sort((a, b) => b.value.compareTo(a.value));
          final secondBest = validCards.length > 1
              ? validCards[1]
              : validCards.first;
          selectedCard = secondBest;
        } else {
          // Comfortable: play medium-strong card to test opponents
          final trumps = validCards.where((c) => c.isTrump).toList();
          if (trumps.isNotEmpty) {
            trumps.sort((a, b) => b.value.compareTo(a.value));
            final middleIndex = (trumps.length * 0.6).round().clamp(
              0,
              trumps.length - 1,
            );
            selectedCard = trumps[middleIndex];
          } else {
            selectedCard = validCards.first;
          }
        }
      } else {
        // Jouer après d'autres: optimisation maximale
        final canWinCards = validCards.where((c) {
          if (c.isExcuse) return true;
          if (!c.isTrump) return false;
          return c.value > (winnerValue ?? 0);
        }).toList();

        if (canWinCards.isNotEmpty) {
          // On peut gagner: choisir la PLUS PETITE carte qui bat le gagnant actuel
          // IMPORTANT: L'Excuse avec valeur 22 est considérée comme carte de valeur 22 pour le tri
          canWinCards.sort((a, b) {
            final aVal = a.isExcuse ? 22 : a.value;
            final bVal = b.isExcuse ? 22 : b.value;
            return aVal.compareTo(bVal);
          });

          // Vérifier s'il reste d'autres joueurs après nous
          final playersAfterUs =
              state.players.length - state.currentTrick.length - 1;

          if (playersAfterUs > 0 && remainingHighTrumps > 0) {
            // Il reste des joueurs et des gros atouts: jouer prudemment
            // Choisir une carte qui bat l'actuel avec une marge de sécurité
            final safeCards = canWinCards
                .where((c) => c.isTrump && c.value > (winnerValue ?? 0) + 2)
                .toList();

            if (safeCards.isNotEmpty) {
              selectedCard = safeCards.first; // La plus petite carte "safe"
            } else {
              selectedCard = canWinCards.first; // La plus petite qui gagne
            }
          } else {
            // Dernier joueur ou pas de menace: jouer la plus petite carte gagnante
            selectedCard = canWinCards.first;
          }
        } else {
          // Ne peut pas gagner ce pli
          if (tricksNeeded >= tricksRemaining - 1) {
            // Très urgent: jouer une carte forte quand même pour les prochains plis
            validCards.sort((a, b) => b.value.compareTo(a.value));
            selectedCard = validCards.first;
          } else {
            // Jouer la plus petite carte pour minimiser les pertes
            validCards.sort((a, b) => a.value.compareTo(b.value));
            selectedCard = validCards.first;
          }
        }
      }
    } else if (tricksNeeded == 0) {
      // Objectif atteint: perdre intelligemment
      if (isFirstCard) {
        // Jouer la plus petite carte non-atout si possible
        final ordinaryCards = validCards
            .where((c) => !c.isTrump && !c.isExcuse)
            .toList();
        if (ordinaryCards.isNotEmpty) {
          ordinaryCards.sort((a, b) => a.value.compareTo(b.value));
          selectedCard = ordinaryCards.first;
        } else {
          // Que des atouts: jouer le plus petit
          validCards.sort((a, b) => a.value.compareTo(b.value));
          final nonExcuse = validCards.where((c) => !c.isExcuse).toList();
          selectedCard = nonExcuse.isNotEmpty
              ? nonExcuse.first
              : validCards.first;
        }
      } else {
        // Jouer une carte qui perd à coup sûr
        final guaranteedLosingCards = validCards.where((c) {
          if (c.isExcuse) return false; // L'Excuse peut gagner
          if (currentWinner?.isTrump ?? false) {
            // Le gagnant est un atout: jouer un atout plus faible ou une carte ordinaire
            if (!c.isTrump) return true;
            return c.value < (winnerValue ?? 0);
          } else {
            // Le gagnant est une carte ordinaire: jouer une carte ordinaire plus faible
            return !c.isTrump && c.value < (winnerValue ?? 0);
          }
        }).toList();

        if (guaranteedLosingCards.isNotEmpty) {
          guaranteedLosingCards.sort((a, b) => a.value.compareTo(b.value));
          selectedCard = guaranteedLosingCards.first;
        } else {
          // Pas de carte perdante garantie: jouer la plus petite
          validCards.sort((a, b) => a.value.compareTo(b.value));
          final nonExcuse = validCards.where((c) => !c.isExcuse).toList();
          selectedCard = nonExcuse.isNotEmpty
              ? nonExcuse.first
              : validCards.first;
        }
      }
    } else {
      // tricksNeeded < 0: dépassé l'objectif
      // Stratégie désespérée: perdre à tout prix
      validCards.sort((a, b) => a.value.compareTo(b.value));
      final ordinaryCards = validCards
          .where((c) => !c.isTrump && !c.isExcuse)
          .toList();
      if (ordinaryCards.isNotEmpty) {
        selectedCard = ordinaryCards.first;
      } else {
        final nonExcuse = validCards.where((c) => !c.isExcuse).toList();
        selectedCard = nonExcuse.isNotEmpty
            ? nonExcuse.first
            : validCards.first;
      }
    }

    // Gestion optimale de l'Excuse
    if (selectedCard.isExcuse) {
      final excuseValue = _chooseExcuseValue(
        state,
        tricksNeeded,
        tricksRemaining,
      );
      return selectedCard.copyWith(excuseValue: excuseValue);
    }

    return selectedCard;
  }

  // ========== HELPER METHODS ==========

  /// Get valid cards that can be played
  List<Card> _getValidCards(GameState state) {
    return state.currentPlayer.hand
        .where((card) => repository.canPlayCard(state, card))
        .toList();
  }

  /// Calculate remaining tricks in current round
  int _calculateTricksRemaining(GameState state, Player player) {
    return (state.cardsPerRound -
            (player.tricksWon +
                state.currentTrick.length ~/ state.players.length))
        .toInt();
  }

  /// Determine who wins the current trick
  Card _getCurrentWinner(List<Card> trick) {
    if (trick.isEmpty) throw StateError('Trick is empty');

    Card winner = trick.first;
    int winnerValue = winner.isExcuse
        ? (winner.excuseValue ?? 0)
        : winner.value;

    for (int i = 1; i < trick.length; i++) {
      final card = trick[i];
      final cardValue = card.isExcuse ? (card.excuseValue ?? 0) : card.value;

      if (card.isExcuse && cardValue == 22) {
        winner = card;
        winnerValue = 22;
      } else if (card.isTrump && !winner.isTrump) {
        winner = card;
        winnerValue = cardValue;
      } else if (card.isTrump && winner.isTrump && cardValue > winnerValue) {
        winner = card;
        winnerValue = cardValue;
      }
    }

    return winner;
  }

  /// Choisit intelligemment la valeur de l'Excuse
  int _chooseExcuseValue(
    GameState state,
    int tricksNeeded,
    int tricksRemaining,
  ) {
    if (tricksNeeded > 0) {
      // Besoin de gagner
      if (tricksNeeded >= tricksRemaining) {
        // Urgent: toujours jouer 22
        return 22;
      } else if (state.currentTrick.isEmpty) {
        // Premier à jouer: jouer 22 pour forcer les autres à jouer fort
        return 22;
      } else {
        // Analyse du pli actuel
        final currentWinner = _getCurrentWinner(state.currentTrick);
        final winnerValue = currentWinner.isExcuse
            ? (currentWinner.excuseValue ?? 0)
            : currentWinner.value;

        // Si le gagnant actuel est faible, on peut gagner avec 22
        if (winnerValue < 20) {
          return 22;
        } else {
          // Le gagnant est très fort: jouer 22 quand même
          return 22;
        }
      }
    } else {
      // Objectif atteint ou dépassé: toujours jouer 0 pour perdre
      return 0;
    }
  }

  /// Récupère toutes les cartes déjà jouées dans cette manche
  List<Card> _getPlayedCards(GameState state) {
    final playedCards = <Card>[];

    // Cartes du pli en cours
    playedCards.addAll(state.currentTrick);

    // Note: pour un vrai card counting, il faudrait garder l'historique des plis précédents
    // dans GameState. Pour l'instant, on ne peut analyser que le pli en cours.

    return playedCards;
  }

  /// Compte les gros atouts restants (valeur >= 18)
  int _countRemainingHighTrumps(List<Card> playedCards, List<Card> hand) {
    // Atouts 18-21 dans la main
    final handHighTrumps = hand.where((c) => c.isTrump && c.value >= 18).length;

    // Dans un vrai card counting, on déduirait aussi les cartes jouées par les autres
    // Pour l'instant, estimation basée uniquement sur notre main
    return handHighTrumps;
  }
}
