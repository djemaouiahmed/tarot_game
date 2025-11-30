import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/card.dart' as game_card;
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import 'card_widget.dart';

class HandReviewWidget extends StatefulWidget {
  final GameState gameState;

  const HandReviewWidget({super.key, required this.gameState});

  @override
  State<HandReviewWidget> createState() => _HandReviewWidgetState();
}

class _HandReviewWidgetState extends State<HandReviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.gameState.currentPlayer;
    final isRound5 = widget.gameState.currentRound == 5;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Titre
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              isRound5
                  ? 'Tour 5 - Pari à l\'aveugle !'
                  : 'Vos cartes pour ce tour',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Information sur le tour
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.casino, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Tour ${widget.gameState.currentRound}/5',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.gameState.cardsPerRound} carte(s) d\'atout par joueur',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (isRound5)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: const Text(
                        '⚠️ Pari à l\'aveugle - Vous voyez les mains des autres !',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Si tour 5, afficher les mains des autres joueurs
          if (isRound5) ...[
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Mains des autres joueurs :',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ..._buildOtherPlayersHands(),
          ] else ...[
            // Sinon, afficher la main du joueur comme avant
            if (currentPlayer.hand.isNotEmpty) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Vos atouts :',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTrumpCards(currentPlayer.hand),
              ),
            ],

            const SizedBox(height: 30),

            if (currentPlayer.ordinaryCards.isNotEmpty) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Vos cartes ordinaires :',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildOrdinaryCards(currentPlayer.ordinaryCards),
              ),
            ],
          ],

          const SizedBox(height: 40),

          // Conseil stratégique
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow, width: 1),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.yellow, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    isRound5
                        ? 'Tour 5 : Vous pariez sans voir vos cartes, mais vous voyez celles des autres !'
                        : _getStrategicAdvice(currentPlayer.hand),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Bouton pour continuer
          FadeTransition(
            opacity: _fadeAnimation,
            child: ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(StartBiddingEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Commencer les paris',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrumpCards(List<game_card.Card> hand) {
    final trumps = hand.where((card) => card.isTrump || card.isExcuse).toList();

    if (trumps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Aucun atout !',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Trier les atouts par valeur
    trumps.sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: trumps.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 100)),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: CardWidget(card: card, width: 70.0, height: 100.0),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdinaryCards(List<game_card.Card> ordinaryCards) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ordinaryCards.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: CardWidget(card: card, width: 50.0, height: 70.0),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getStrategicAdvice(List<game_card.Card> hand) {
    final trumps = hand.where((card) => card.isTrump).toList();
    final strongTrumps = trumps.where((card) => card.value >= 15).length;
    final mediumTrumps = trumps
        .where((card) => card.value >= 10 && card.value < 15)
        .length;
    final excuse = hand.any((card) => card.isExcuse);

    if (trumps.isEmpty) {
      return 'Attention ! Vous n\'avez aucun atout. Pariez 0 pli car seuls les atouts peuvent gagner des plis.';
    }

    if (strongTrumps >= 3) {
      return 'Excellente main ! Vous avez $strongTrumps atouts forts. Vous pouvez parier audacieusement.';
    }

    if (strongTrumps >= 1 && mediumTrumps >= 1) {
      return 'Bonne main avec ${strongTrumps + mediumTrumps} atouts. Pariez prudemment selon votre position.';
    }

    if (mediumTrumps >= 2) {
      return 'Main moyenne avec $mediumTrumps atouts moyens. Pariez modestement.';
    }

    if (excuse) {
      return 'Vous avez l\'Excuse ! Elle ne gagne jamais mais vous la récupérez toujours.';
    }

    return 'Main faible. Pariez peu de plis et jouez prudemment.';
  }

  List<Widget> _buildOtherPlayersHands() {
    final widgets = <Widget>[];

    for (int i = 0; i < widget.gameState.players.length; i++) {
      if (i == widget.gameState.currentPlayerIndex) {
        continue; // Ne pas afficher la main du joueur actuel
      }

      final player = widget.gameState.players[i];

      widgets.add(
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: player.hand.map((card) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: CardWidget(
                            card: card,
                            width: 50.0,
                            height: 70.0,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
