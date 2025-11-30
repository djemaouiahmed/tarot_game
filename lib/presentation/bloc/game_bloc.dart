import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card.dart' as game_card;
import '../../domain/entities/player.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/start_game.dart';
import '../../domain/usecases/make_bid.dart';
import '../../domain/usecases/play_card.dart';
import '../../domain/usecases/get_bot_move.dart';
import '../../domain/usecases/clear_trick.dart';
import 'game_event.dart';
import 'game_state_bloc.dart';
import '../../domain/entities/bot_difficulty.dart';

// BLoC principal pour la gestion de l'état du jeu
// Gère tous les événements du jeu (démarrage, mises, cartes jouées, tours des bots, etc.)
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  // Use cases injectés pour les opérations métier
  final StartGame startGame;
  final MakeBid makeBid;
  final PlayCard playCard;
  final GetBotMove getBotMove;
  final ClearTrick clearTrick;

  // Difficulté des bots configurée au démarrage de la partie
  BotDifficulty _botDifficulty = BotDifficulty.medium;

  GameBloc({
    required this.startGame,
    required this.makeBid,
    required this.playCard,
    required this.getBotMove,
    required this.clearTrick,
  }) : super(const GameInitial()) {
    // Enregistrement des handlers pour chaque type d'événement
    on<StartGameEvent>(_onStartGame); // Démarrer une nouvelle partie
    on<ReviewHandEvent>(_onReviewHand); // Revoir les cartes distribuées
    on<StartBiddingEvent>(_onStartBidding); // Commencer la phase d'annonces
    on<MakeBidEvent>(_onMakeBid); // Placer une mise
    on<PlayCardEvent>(_onPlayCard); // Jouer une carte
    on<BotTurnEvent>(_onBotTurn); // Tour du bot
    on<NextRoundEvent>(_onNextRound); // Passer au tour suivant
    on<RestartGameEvent>(_onRestartGame); // Redémarrer la partie
    on<AnimationCompleteEvent>(_onAnimationComplete); // Animation terminée
    on<ClearTrickEvent>(_onClearTrick); // Nettoyer le pli
  }

  // Handler pour démarrer une nouvelle partie
  Future _onStartGame(StartGameEvent event, Emitter<GameBlocState> emit) async {
    emit(const GameLoading());
    try {
      // Enregistrer la difficulté choisie pour les bots
      _botDifficulty = event.difficulty;

      final gameState = await startGame(
        event.numberOfPlayers,
        initialCards: event.initialCards,
        startingLives: event.startingLives,
      );
      // Démarrer avec la phase de revue des cartes distribuées
      final reviewState = GameState(
        players: gameState.players,
        dealerIndex: gameState.dealerIndex,
        currentPlayerIndex: 0, // Commencer avec le joueur humain
        phase: GamePhase.handReview,
        currentRound: gameState.currentRound,
        initialCards: gameState.initialCards,
        bids: gameState.bids,
        currentTrick: gameState.currentTrick,
        isLastCardBlind: gameState.isLastCardBlind,
      );
      emit(GameLoaded(reviewState));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  // Handler pour placer une mise pendant la phase d'annonces
  Future _onMakeBid(MakeBidEvent event, Emitter emit) async {
    if (state is! GameLoaded) return;

    final currentState = (state as GameLoaded).gameState;

    try {
      final newState = await makeBid(
        currentState,
        currentState.currentPlayer.id,
        event.bid,
      );
      emit(GameLoaded(newState));

      // Si le joueur suivant est un bot et on est toujours en phase d'annonces
      if (newState.phase == GamePhase.bidding &&
          newState.currentPlayer.type == PlayerType.bot) {
        add(BotTurnEvent());
      } else if (newState.phase == GamePhase.playing &&
          newState.currentPlayer.type == PlayerType.bot) {
        // Si on passe à la phase de jeu et c'est un bot
        add(BotTurnEvent());
      }
    } catch (e) {
      emit(GameError(e.toString()));
      // Retourner à l'état précédent après une courte pause
      await Future.delayed(const Duration(seconds: 2));
      emit(GameLoaded(currentState));
    }
  }

  // Handler pour jouer une carte
  Future _onPlayCard(PlayCardEvent event, Emitter emit) async {
    if (state is! GameLoaded) return;

    final currentState = (state as GameLoaded).gameState;

    try {
      final newState = await playCard(currentState, event.card);
      emit(GameLoaded(newState));

      // Si le pli est complet et en cours d'animation
      if (newState.isAnimating && newState.currentTrick.isNotEmpty) {
        // Attendre 1.9s pour l'animation du pli (0.3s délai + 1.2s visible + 0.4s fondu)
        await Future.delayed(const Duration(milliseconds: 1900));
        // Nettoyer le pli
        add(ClearTrickEvent());
        return;
      }

      // Si le joueur suivant est un bot
      if (newState.phase == GamePhase.playing &&
          newState.currentPlayer.type == PlayerType.bot &&
          !newState.isAnimating) {
        // Petit délai avant que le bot ne joue
        await Future.delayed(const Duration(milliseconds: 500));
        add(BotTurnEvent());
      }
      // Ne pas appeler NextRoundEvent ici car le score debrief le fait déjà
    } catch (e) {
      emit(GameError(e.toString()));
      await Future.delayed(const Duration(seconds: 2));
      emit(GameLoaded(currentState));
    }
  }

  // Handler pour nettoyer le pli après sa complétion
  Future _onClearTrick(ClearTrickEvent event, Emitter emit) async {
    if (state is! GameLoaded) return;

    final currentState = (state as GameLoaded).gameState;

    try {
      // Si en phase de calcul des scores, appeler calculateScores
      if (currentState.phase == GamePhase.scoring) {
        final scoredState = await playCard.repository.calculateScores(
          currentState,
        );
        emit(GameLoaded(scoredState));
        return;
      }

      final newState = await clearTrick(currentState);
      emit(GameLoaded(newState));

      // Si le joueur suivant est un bot, déclencher son tour
      if (newState.phase == GamePhase.playing &&
          newState.currentPlayer.type == PlayerType.bot) {
        await Future.delayed(const Duration(milliseconds: 500));
        add(BotTurnEvent());
      }
    } catch (e) {
      emit(GameError(e.toString()));
      await Future.delayed(const Duration(seconds: 2));
      emit(GameLoaded(currentState));
    }
  }

  Future _onBotTurn(BotTurnEvent event, Emitter emit) async {
    if (state is! GameLoaded) return;

    final currentState = (state as GameLoaded).gameState;

    // Délai pour simuler la réflexion du bot
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Utiliser la difficulté choisie par l'utilisateur
      final botMove = await getBotMove(currentState, _botDifficulty);

      if (currentState.phase == GamePhase.bidding) {
        if (botMove is int) {
          add(MakeBidEvent(botMove));
        }
      } else if (currentState.phase == GamePhase.playing) {
        if (botMove is game_card.Card) {
          add(PlayCardEvent(botMove));
        }
      }
    } catch (e) {
      emit(GameError('Erreur du bot: ${e.toString()}'));
      await Future.delayed(const Duration(seconds: 2));
      emit(GameLoaded(currentState));
    }
  }

  Future _onNextRound(NextRoundEvent event, Emitter emit) async {
    if (state is! GameLoaded) return;

    final currentState = (state as GameLoaded).gameState;

    // Décider si on passe au tour suivant ou à la main suivante
    GameState nextState;
    if (currentState.currentRound < 5) {
      // Tour suivant dans la même main
      final nextDealerIndex =
          (currentState.dealerIndex + 1) % currentState.players.length;
      final tempState = GameState(
        players: currentState.players,
        dealerIndex: nextDealerIndex,
        currentPlayerIndex: currentState.currentPlayerIndex,
        phase: GamePhase.bidding,
        currentRound: currentState.currentRound,
        bids: currentState.bids,
        currentTrick: [],
        isLastCardBlind: false,
        initialCards: currentState.initialCards,
      );
      nextState = await playCard.repository.nextRound(tempState);
    } else {
      // Main suivante
      final tempState = GameState(
        players: currentState.players,
        dealerIndex: currentState.dealerIndex,
        currentPlayerIndex: currentState.currentPlayerIndex,
        phase: GamePhase.bidding,
        currentRound: currentState.currentRound,
        bids: currentState.bids,
        currentTrick: [],
        isLastCardBlind: false,
        initialCards: currentState.initialCards,
      );
      nextState = await playCard.repository.nextHand(tempState);
    }

    emit(GameLoaded(nextState));

    // Si le premier joueur du nouveau tour est un bot
    if (nextState.currentPlayer.type == PlayerType.bot) {
      add(BotTurnEvent());
    }
  }

  Future _onReviewHand(
    ReviewHandEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is! GameLoaded) return;

    // Continuer à la phase de visualisation pour le prochain joueur humain
    // ou commencer les paris si tous les joueurs ont vu leur main
    add(StartBiddingEvent());
  }

  Future _onStartBidding(
    StartBiddingEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is! GameLoaded) return;
    final currentState = (state as GameLoaded).gameState;

    final biddingState = GameState(
      players: currentState.players,
      dealerIndex: currentState.dealerIndex,
      currentPlayerIndex:
          (currentState.dealerIndex + 1) % currentState.players.length,
      phase: GamePhase.bidding,
      currentRound: currentState.currentRound,
      bids: currentState.bids,
      currentTrick: currentState.currentTrick,
      isLastCardBlind: currentState.isLastCardBlind,
      initialCards: currentState.initialCards,
    );

    emit(GameLoaded(biddingState));

    // Si le premier joueur à parier est un bot
    if (biddingState.currentPlayer.type == PlayerType.bot) {
      add(BotTurnEvent());
    }
  }

  Future _onAnimationComplete(
    AnimationCompleteEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is! GameLoaded) return;
    final currentState = (state as GameLoaded).gameState;

    // Terminer l'animation et continuer le jeu
    final newState = GameState(
      players: currentState.players,
      dealerIndex: currentState.dealerIndex,
      currentPlayerIndex: currentState.currentPlayerIndex,
      phase: currentState.phase,
      currentRound: currentState.currentRound,
      bids: currentState.bids,
      currentTrick: currentState.currentTrick,
      isLastCardBlind: currentState.isLastCardBlind,
      isAnimating: false,
      lastPlayedCard: null,
      lastPlayerIndex: null,
    );

    emit(GameLoaded(newState));
  }

  Future _onRestartGame(
    RestartGameEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(const GameInitial());
  }
}
