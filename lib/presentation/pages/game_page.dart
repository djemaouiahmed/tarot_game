import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state_bloc.dart';
import '../widgets/bid_dialog.dart';
import '../widgets/game_board.dart';
import '../widgets/player_board.dart';
import '../widgets/hand_review_widget.dart';
import '../widgets/player_hand_widget.dart';
import '../widgets/trick_animation_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/game_over_widget.dart';
import '../widgets/score_debrief_widget.dart';
import '../widgets/game_menu_drawer.dart';
import '../../domain/entities/player.dart';
import '../../core/audio/audio_service.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _showScoreDebrief = false;
  Map<String, int> _oldScores = {};
  GamePhase? _lastPhase;
  double _volume = 0.5;

  void _checkForScoreDebrief(GameState gameState) {
    // Sauvegarder les scores quand la dernière carte est jouée (avant calculateScores)
    if (gameState.phase == GamePhase.playing &&
        gameState.currentTrick.isNotEmpty &&
        gameState.players.isNotEmpty) {
      // Vérifier si c'est le dernier pli (toutes les mains sont vides ou presque)
      final allHandsEmpty = gameState.players.every((p) => p.hand.isEmpty);
      final almostEmpty = gameState.players.every((p) => p.hand.length <= 1);

      if ((allHandsEmpty || almostEmpty) && _oldScores.isEmpty) {
        // Sauvegarder MAINTENANT les scores avant calculateScores
        _oldScores = {for (var p in gameState.players) p.id: p.score};
      }
    }

    // Afficher le débrief quand on entre dans scoring OU bidding après scoring
    if (_oldScores.isNotEmpty &&
        (_lastPhase == GamePhase.scoring ||
            gameState.phase == GamePhase.scoring) &&
        !_showScoreDebrief &&
        !gameState.isAnimating) {
      // Attendre que l'animation du pli soit terminée

      // Délai de 0.5s avant d'afficher le débrief
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showScoreDebrief = true;
          });

          // Debrief will auto-close after 15s or via skip button
          Future.delayed(const Duration(milliseconds: 10000), () {
            if (mounted && _showScoreDebrief) {
              setState(() {
                _showScoreDebrief = false;
                _oldScores = {}; // Reset for next round
              });
              // Launch next round after auto-close
              context.read<GameBloc>().add(NextRoundEvent());
            }
          });
        }
      });
    }

    _lastPhase = gameState.phase;
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Quitter la partie ?',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter ?\nLa partie en cours sera perdue.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Fermer le dialogue
              Navigator.pop(context); // Retourner au menu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Quitter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GameMenuDrawer(
        volume: _volume,
        onVolumeChanged: (value) {
          setState(() {
            _volume = value;
          });
          // Mettre à jour le volume du service audio
          AudioService().setVolume(value);
        },
        onQuit: () => _showExitConfirmation(context),
      ),
      // appBar: AppBar(
      //   title: const Text(
      //     'Tarot Africain',
      //     style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade600],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1B5E20), // Deep green center
              Color(0xFF0D3818), // Darker green
              Color(0xFF051810), // Almost black edges
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Vignette overlay for depth
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),

            // Subtle light rays from top
            Positioned(
              top: -100,
              left: -100,
              right: -100,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      Colors.amber.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            BlocBuilder<GameBloc, GameBlocState>(
              builder: (context, state) {
                // 1. Handle Initial (waiting for start) OR Loading
                if (state is GameInitial || state is GameLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                // 2. Handle Loaded (Game Active)
                if (state is GameLoaded) {
                  // Vérifier si on doit afficher le debrief des scores
                  _checkForScoreDebrief(state.gameState);

                  // Phase de fin de partie
                  if (state.gameState.phase == GamePhase.gameOver) {
                    final winner = state.gameState.players.reduce(
                      (current, next) =>
                          current.score > next.score ? current : next,
                    );

                    return GameOverWidget(
                      winner: winner,
                      allPlayers: state.gameState.players,
                      onNewGame: () {
                        Navigator.of(context).pop();
                      },
                    );
                  }

                  // Phase de visualisation de la main
                  if (state.gameState.phase == GamePhase.handReview) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.deepPurple.shade800,
                            Colors.deepPurple.shade600,
                          ],
                        ),
                      ),
                      child: HandReviewWidget(gameState: state.gameState),
                    );
                  }

                  // Phases normales du jeu
                  return Stack(
                    children: [
                      Column(
                        children: [
                          ScoreBoard(gameState: state.gameState),
                          Expanded(
                            child: state.gameState.phase == GamePhase.playing
                                ? PlayerBoard(
                                    gameState: state.gameState,
                                    currentPlayerId:
                                        state.gameState.currentPlayer.id,
                                  )
                                : GameBoard(gameState: state.gameState),
                          ),
                          if (state.gameState.phase == GamePhase.bidding)
                            BidControls(gameState: state.gameState),
                          if (state.gameState.phase == GamePhase.playing)
                            PlayerHandWidget(
                              cards: state.gameState.players
                                  .firstWhere((p) => p.type == PlayerType.human)
                                  .hand,
                              isPlayerTurn:
                                  state.gameState.currentPlayer.type ==
                                  PlayerType.human,
                              onCardTap: (card) {
                                context.read<GameBloc>().add(
                                  PlayCardEvent(card),
                                );
                              },
                            ),
                        ],
                      ),

                      // Overlay d'animation de fin de pli
                      if (state.gameState.isAnimating &&
                          state.gameState.currentTrick.isNotEmpty)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: TrickAnimationWidget(
                              gameState: state.gameState,
                              winnerIndex: state.gameState.currentPlayerIndex,
                            ),
                          ),
                        ),

                      // Score debrief overlay (5 seconds with skip button)
                      if (_showScoreDebrief)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: ScoreDebriefWidget(
                              players: state.gameState.players,
                              oldScores: _oldScores,
                              roundNumber: state.gameState.currentRound,
                              onDismiss: () {
                                setState(() {
                                  _showScoreDebrief = false;
                                  _oldScores = {}; // Reset quand on skip
                                });
                                // Lancer le prochain tour après fermeture du debrief
                                context.read<GameBloc>().add(NextRoundEvent());
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                }

                // 3. Handle Error explicitly to see the message
                if (state is GameError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Erreur: ${state.message}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Retour"),
                        ),
                      ],
                    ),
                  );
                }

                // Fallback for any unhandled state
                return Center(
                  child: Text(
                    "État inconnu: $state",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
