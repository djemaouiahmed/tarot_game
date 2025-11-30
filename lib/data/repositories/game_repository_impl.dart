import 'dart:math';
import '../../domain/entities/card.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;
  final Random _random = Random();

  GameRepositoryImpl(this.localDataSource);

  @override
  Future initializeGame(int numberOfPlayers, {int initialCards = 5}) async {
    // Valider le nombre de joueurs
    if (numberOfPlayers < 3 || numberOfPlayers > 4) {
      throw ArgumentError('Le nombre de joueurs doit être 3 ou 4');
    }

    // Créer les joueurs
    final players = _createPlayers(numberOfPlayers);

    // Distribuer les paquets de cartes ordinaires face visible
    _distributeOrdinaryCards(players);

    // Créer l'état initial
    GameState state = GameState(
      players: players,
      dealerIndex: 0,
      currentPlayerIndex: 0, // Commencer par le joueur humain pour voir sa main
      phase: GamePhase.handReview, // Visualisation de la main avant les paris
      currentRound: 1,
      initialCards: initialCards,
      bids: [],
      currentTrick: [],
      isLastCardBlind: false,
    );

    // Distribuer les cartes pour le premier tour
    state = await dealCards(state);

    return state;
  }

  /// Crée la liste des joueurs
  List<Player> _createPlayers(int numberOfPlayers) {
    final players = <Player>[];

    // Joueur humain
    players.add(
      Player(
        id: 'player_0',
        name: 'Vous',
        type: PlayerType.human,
        score: 14, // On commence avec 14 points (roi)
      ),
    );

    // Joueurs bots
    for (int i = 1; i < numberOfPlayers; i++) {
      players.add(
        Player(
          id: 'player_$i',
          name: 'Bot $i',
          type: PlayerType.bot,
          score: 14,
        ),
      );
    }

    return players;
  }

  /// Distribue les paquets de cartes ordinaires à chaque joueur
  void _distributeOrdinaryCards(List<Player> players) {
    // Tarot Africain: chaque joueur reçoit un paquet d'une couleur, trié par ordre décroissant
    final suits = [
      CardSuit.clubs,
      CardSuit.spades,
      CardSuit.diamonds,
      CardSuit.hearts,
    ];

    for (int i = 0; i < players.length; i++) {
      final suit = suits[i % suits.length];
      final ordinaryCards = <Card>[];

      // Ordre décroissant traditionnel: Roi (14) jusqu'à As (1) en dernier
      final ranks = [
        CardRank.king, // 14
        CardRank.queen, // 13
        CardRank.knight, // 12
        CardRank.jack, // 11
        CardRank.ten, // 10
        CardRank.nine, // 9
        CardRank.eight, // 8
        CardRank.seven, // 7
        CardRank.six, // 6
        CardRank.five, // 5
        CardRank.four, // 4
        CardRank.three, // 3
        CardRank.two, // 2
        CardRank.ace, // 1 (en dernier selon les règles)
      ];

      // Valeurs selon l'ordre traditionnel du Tarot Africain
      int value = 14;
      for (final rank in ranks) {
        ordinaryCards.add(Card(suit: suit, rank: rank, value: value));
        value--;
      }

      players[i] = players[i].copyWith(ordinaryCards: ordinaryCards);
    }
  }

  @override
  Future dealCards(GameState state) async {
    final cardsPerPlayer = state.cardsPerRound;
    final trumpDeck = _createTrumpDeck();

    // Mélanger le paquet d'atouts
    trumpDeck.shuffle(_random);

    // Distribuer les cartes à chaque joueur
    final updatedPlayers = <Player>[];
    int cardIndex = 0;

    for (final player in state.players) {
      final hand = trumpDeck.sublist(cardIndex, cardIndex + cardsPerPlayer);
      updatedPlayers.add(
        player.copyWith(hand: hand, tricksWon: 0, currentBid: 0),
      );
      cardIndex += cardsPerPlayer;
    }

    return GameState(
      players: updatedPlayers,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex:
          0, // Commencer par le joueur humain pour la visualisation
      phase: GamePhase.handReview, // Phase de visualisation de la main
      currentRound: state.currentRound,
      bids: [],
      currentTrick: [],
      isLastCardBlind:
          state.currentRound == 5, // Dernier tour = carte sur le front
      initialCards: state.initialCards,
    );
  }

  /// Crée le paquet d'atouts (21 atouts + excuse)
  List<Card> _createTrumpDeck() {
    final deck = <Card>[];

    // Ajouter les 21 atouts
    for (int i = 1; i <= 21; i++) {
      deck.add(
        Card(
          suit: CardSuit.trump,
          rank: CardRank.values[CardRank.trump1.index + i - 1],
          value: i,
        ),
      );
    }

    // Ajouter l'excuse (peut valoir 0 ou 22)
    deck.add(Card(suit: CardSuit.excuse, rank: CardRank.excuse, value: 0));

    return deck;
  }

  @override
  Future recordBid(GameState state, String playerId, int bid) async {
    final playerIndex = state.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) {
      throw ArgumentError('Joueur non trouvé');
    }

    // Valider le pari
    if (bid < 0 || bid > state.cardsPerRound) {
      throw ArgumentError('Pari invalide');
    }

    // Créer une nouvelle liste de paris avec le pari au bon index
    final updatedBids = List<int>.from(state.bids);

    // S'assurer que la liste a la bonne taille
    while (updatedBids.length <= playerIndex) {
      updatedBids.add(-1); // Valeur temporaire pour les paris non faits
    }

    // Placer le pari à l'index du joueur
    updatedBids[playerIndex] = bid; // Enregistrer le pari dans le joueur
    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
      currentBid: bid,
    );

    // Passer au joueur suivant ou à la phase de jeu
    final nextPlayerIndex =
        (state.currentPlayerIndex + 1) % state.players.length;
    final allBidsIn =
        updatedBids.where((b) => b >= 0).length == state.players.length;

    return GameState(
      players: updatedPlayers,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: allBidsIn
          ? (state.dealerIndex + 1) % state.players.length
          : nextPlayerIndex,
      phase: allBidsIn ? GamePhase.playing : GamePhase.bidding,
      currentRound: state.currentRound,
      bids: updatedBids,
      currentTrick: [],
      isLastCardBlind: state.isLastCardBlind,
      initialCards: state.initialCards,
    );
  }

  @override
  Future playCard(GameState state, Card card) async {
    // Vérifier que la carte peut être jouée
    if (!canPlayCard(state, card)) {
      throw ArgumentError('Cette carte ne peut pas être jouée');
    }

    // Retirer la carte de la main du joueur
    // Pour l'Excuse, on compare par suit et rank au lieu de l'objet complet
    final currentPlayer = state.currentPlayer;
    final updatedHand = currentPlayer.hand.where((c) {
      // Comparer par suit et rank pour gérer l'Excuse avec valeur modifiée
      return !(c.suit == card.suit && c.rank == card.rank);
    }).toList();

    final List<Player> updatedPlayers = List.from(state.players);
    updatedPlayers[state.currentPlayerIndex] = currentPlayer.copyWith(
      hand: updatedHand,
    );

    // Ajouter la carte au pli actuel (avec la valeur choisie pour l'Excuse)
    final updatedTrick = [...state.currentTrick, card];

    // Si le pli est complet
    if (updatedTrick.length == state.players.length) {
      return _completeTrick(state, updatedTrick, updatedPlayers);
    }

    // Passer au joueur suivant
    return GameState(
      players: updatedPlayers,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length,
      phase: GamePhase.playing,
      currentRound: state.currentRound,
      bids: state.bids,
      currentTrick: updatedTrick,
      isLastCardBlind: state.isLastCardBlind,
      initialCards: state.initialCards,
    );
  }

  /// Termine un pli et détermine le gagnant
  Future _completeTrick(
    GameState state,
    List<Card> trick,
    List<Player> players,
  ) async {
    // Déterminer qui a commencé le pli
    final leadPlayerIndex =
        (state.currentPlayerIndex - trick.length + 1 + state.players.length) %
        state.players.length;

    // Trouver le gagnant du pli
    final winnerOffset = getTrickWinner(trick, leadPlayerIndex);
    final absoluteWinnerIndex =
        (leadPlayerIndex + winnerOffset) % players.length;

    // Gérer l'Excuse: elle est récupérée par son propriétaire
    final updatedPlayers = <Player>[];
    for (int i = 0; i < players.length; i++) {
      Player player = players[i];

      // Si ce joueur a joué l'Excuse, il la récupère
      final playedCardIndex =
          (i - leadPlayerIndex + players.length) % players.length;
      if (playedCardIndex < trick.length && trick[playedCardIndex].isExcuse) {
        // L'Excuse retourne dans la main du joueur (ou dans ses plis gagnés)
        // Pour simplifier, on considère qu'elle compte comme un demi-pli
      }

      // Incrémenter les plis gagnés pour le gagnant
      if (i == absoluteWinnerIndex) {
        player = player.copyWith(tricksWon: player.tricksWon + 1);
      }

      updatedPlayers.add(player);
    }

    // Si tous les plis sont joués, afficher quand même l'animation du dernier pli
    if (updatedPlayers[0].hand.isEmpty) {
      return GameState(
        players: updatedPlayers,
        dealerIndex: state.dealerIndex,
        currentPlayerIndex: absoluteWinnerIndex,
        phase: GamePhase.scoring,
        currentRound: state.currentRound,
        bids: state.bids,
        currentTrick: trick, // Garder les cartes pour l'animation
        isLastCardBlind: state.isLastCardBlind,
        isAnimating: true, // Afficher l'animation du dernier pli
        lastPlayedCard: trick.last,
        lastPlayerIndex: (leadPlayerIndex + trick.length - 1) % players.length,
        initialCards: state.initialCards,
      );
    }

    // Phase d'animation : montrer le pli complet avant de le vider
    // Le BLoC devra gérer un délai avant de passer au pli suivant
    return GameState(
      players: updatedPlayers,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: absoluteWinnerIndex,
      phase: GamePhase.playing,
      currentRound: state.currentRound,
      bids: state.bids,
      currentTrick: trick, // Garder les cartes visibles pour l'animation
      isLastCardBlind: state.isLastCardBlind,
      isAnimating: true, // Signaler qu'on est en animation de fin de pli
      lastPlayedCard: trick.last,
      lastPlayerIndex: (leadPlayerIndex + trick.length - 1) % players.length,
      initialCards: state.initialCards,
    );
  }

  @override
  Future clearTrickAfterAnimation(GameState state) async {
    // Vider le pli et désactiver l'animation
    return GameState(
      players: state.players,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: state.currentPlayerIndex,
      phase: GamePhase.playing,
      currentRound: state.currentRound,
      bids: state.bids,
      currentTrick: [], // Vider le pli
      isLastCardBlind: state.isLastCardBlind,
      isAnimating: false, // Désactiver l'animation
      lastPlayedCard: null,
      lastPlayerIndex: null,
      initialCards: state.initialCards,
    );
  }

  @override
  bool canPlayCard(GameState state, Card card) {
    final currentPlayer = state.currentPlayer;

    // L'excuse peut toujours être jouée
    if (card.isExcuse) {
      return true;
    }

    // Si c'est la première carte du pli, toutes les cartes sont valides
    if (state.currentTrick.isEmpty) {
      return true;
    }

    // Tarot Africain: OBLIGATION de jouer un atout si on en possède un
    final hasAtouts = currentPlayer.hand.any((c) => c.isTrump && !c.isExcuse);
    if (hasAtouts) {
      // On DOIT jouer un atout
      return card.isTrump;
    }

    // Si on n'a plus d'atouts, on peut jouer une carte ordinaire
    return !card.isTrump;
  }

  @override
  int getTrickWinner(List<Card> trick, int leadPlayerIndex) {
    int winnerIndex = 0;
    Card winningCard = trick[0];

    // Tarot Africain: seuls les atouts (et l'Excuse avec valeur) peuvent gagner des plis
    for (int i = 0; i < trick.length; i++) {
      final currentCard = trick[i];

      // L'Excuse avec valeur 22 peut gagner, sinon elle ne gagne jamais
      if (currentCard.isExcuse) {
        if (currentCard.effectiveValue == 22) {
          // L'Excuse à 22 bat tout - c'est la carte la plus forte
          winningCard = currentCard;
          winnerIndex = i;
        }
        // Si effectiveValue == 0, on skip cette carte
        continue;
      }

      // Seuls les atouts peuvent gagner
      if (currentCard.isTrump) {
        // IMPORTANT: L'Excuse à 22 ne peut JAMAIS être battue
        if (winningCard.isExcuse && winningCard.effectiveValue == 22) {
          // L'Excuse à 22 est imbattable, on skip cette carte
          continue;
        }

        // L'atout bat la carte gagnante actuelle si :
        // - la carte gagnante n'est pas un atout OU
        // - l'atout est plus fort que la carte gagnante atout
        if (!winningCard.isTrump ||
            currentCard.effectiveValue > winningCard.effectiveValue) {
          winningCard = currentCard;
          winnerIndex = i;
        }
      }
    }

    // Si aucun atout n'a été joué, le premier joueur gagne par défaut
    if (!winningCard.isTrump && !winningCard.isExcuse) {
      winnerIndex = 0;
    }

    return winnerIndex;
  }

  @override
  Future calculateScores(GameState state) async {
    final updatedPlayers = <Player>[];

    for (int i = 0; i < state.players.length; i++) {
      final player = state.players[i];

      // Vérifier que le joueur a un pari valide
      if (i >= state.bids.length || state.bids[i] < 0) {
        // Pas de pari valide pour ce joueur, le garder tel quel
        updatedPlayers.add(player);
        continue;
      }

      final bid = state.bids[i];
      final tricksWon = player.tricksWon;

      // Calcul simple : diminuer la différence entre le pari et les plis gagnés
      final difference = (tricksWon - bid).abs();
      final newScore = player.score - difference;

      // Retirer des cartes ordinaires pour chaque point perdu
      List<Card> updatedOrdinaryCards = List<Card>.from(player.ordinaryCards);

      if (difference > 0 && updatedOrdinaryCards.isNotEmpty) {
        // Trier les cartes par valeur décroissante pour retirer les plus fortes d'abord
        updatedOrdinaryCards.sort((a, b) {
          // Ordre : King (4) > Queen (3) > Knight (2) > Jack (1) > autres
          int getCardValue(Card card) {
            if (card.rank == CardRank.king) return 4;
            if (card.rank == CardRank.queen) return 3;
            if (card.rank == CardRank.knight) return 2;
            if (card.rank == CardRank.jack) return 1;
            return 0; // Cartes numériques
          }

          final valueA = getCardValue(a);
          final valueB = getCardValue(b);

          if (valueA != valueB) {
            return valueB.compareTo(valueA); // Décroissant
          }
          // Si même rang, trier par valeur de carte
          return b.value.compareTo(a.value);
        });

        // Retirer le nombre de cartes correspondant aux points perdus
        final cardsToRemove = difference.clamp(0, updatedOrdinaryCards.length);
        updatedOrdinaryCards = updatedOrdinaryCards.sublist(cardsToRemove);
      }

      updatedPlayers.add(
        player.copyWith(score: newScore, ordinaryCards: updatedOrdinaryCards),
      );
    }

    // Vérifier si quelqu'un est à 0 ou moins
    final gameOver = updatedPlayers.any((p) => p.score <= 0);

    if (gameOver) {
      return GameState(
        players: updatedPlayers,
        dealerIndex: state.dealerIndex,
        currentPlayerIndex: state.currentPlayerIndex,
        phase: GamePhase.gameOver,
        currentRound: state.currentRound,
        bids: state.bids,
        currentTrick: [],
        isLastCardBlind: false,
        initialCards: state.initialCards,
      );
    }

    // Rester en phase scoring pour afficher le debrief
    // Le prochain tour sera lancé après la fermeture du debrief
    return GameState(
      players: updatedPlayers,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: state.currentPlayerIndex,
      phase: GamePhase.scoring,
      currentRound: state.currentRound,
      bids: state.bids,
      currentTrick: [],
      isLastCardBlind: false,
      initialCards: state.initialCards,
    );
  }

  @override
  Future nextRound(GameState state) async {
    final newState = GameState(
      players: state.players,
      dealerIndex: state.dealerIndex,
      currentPlayerIndex: (state.dealerIndex + 1) % state.players.length,
      phase: GamePhase.bidding,
      currentRound: state.currentRound + 1,
      bids: [],
      currentTrick: [],
      isLastCardBlind: state.currentRound + 1 == 5,
      initialCards: state.initialCards,
    );

    return await dealCards(newState);
  }

  @override
  Future nextHand(GameState state) async {
    final newDealerIndex = (state.dealerIndex + 1) % state.players.length;

    final newState = GameState(
      players: state.players,
      dealerIndex: newDealerIndex,
      currentPlayerIndex: (newDealerIndex + 1) % state.players.length,
      phase: GamePhase.bidding,
      currentRound: 1,
      bids: [],
      currentTrick: [],
      isLastCardBlind: false,
      initialCards: state.initialCards,
    );

    return await dealCards(newState);
  }
}
