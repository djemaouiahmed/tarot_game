import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/card.dart' as game_card;
import 'card_widget.dart';
import 'bid_token_widget.dart';

class PlayerBoard extends StatefulWidget {
  final GameState gameState;
  final String currentPlayerId;

  const PlayerBoard({
    super.key,
    required this.gameState,
    required this.currentPlayerId,
  });

  @override
  State<PlayerBoard> createState() => _PlayerBoardState();
}

class _PlayerBoardState extends State<PlayerBoard>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardAnimationControllers;
  late List<Animation<Offset>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _cardAnimationControllers = List.generate(
      4, // Maximum 4 joueurs
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _cardAnimations = _cardAnimationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0),
        end: const Offset(0, -0.5),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trouver les bots dans un ordre fixe
    final botPlayers = widget.gameState.players
        .where((p) => p.type == PlayerType.bot)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Joueurs du haut (bots en positions fixes)
          _buildOpponentRow(botPlayers),

          const SizedBox(height: 12),

          // Zone centrale de jeu
          Flexible(child: _buildCenterTable()),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOpponentRow(List<Player> botPlayers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: botPlayers.map((player) {
        return _buildOpponentPlayer(player);
      }).toList(),
    );
  }

  Widget _buildOpponentPlayer(Player player) {
    final playerIndex = widget.gameState.players.indexOf(player);
    final isCurrentTurn = widget.gameState.currentPlayer.id == player.id;
    final bidIndex = widget.gameState.players.indexOf(player);
    final hasBid = bidIndex < widget.gameState.bids.length;
    final bid = hasBid ? widget.gameState.bids[bidIndex] : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCurrentTurn
              ? [
                  Colors.blue.shade700.withOpacity(0.6),
                  Colors.blue.shade900.withOpacity(0.8),
                ]
              : [
                  Colors.deepPurple.shade800.withOpacity(0.4),
                  Colors.deepPurple.shade900.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentTurn
              ? Colors.cyanAccent
              : Colors.amber.withOpacity(0.3),
          width: isCurrentTurn ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentTurn
                ? Colors.blue.withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            blurRadius: isCurrentTurn ? 15 : 8,
            spreadRadius: isCurrentTurn ? 3 : 1,
          ),
          if (isCurrentTurn)
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          // Player name with modern badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrentTurn
                    ? [Colors.cyanAccent.shade400, Colors.blue.shade600]
                    : [Colors.amber.shade600, Colors.orange.shade800],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isCurrentTurn
                      ? Colors.cyanAccent.withOpacity(0.5)
                      : Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cards with glow effect
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: _buildHiddenCards(player, playerIndex),
          ),

          const SizedBox(height: 10),

          // Stats row with modern design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score
                _buildStatBadge(
                  icon: Icons.stars_rounded,
                  label: '${player.score}',
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                // Bid token
                if (bid != null && bid > 0) ...[
                  PlayerBidToken(bidValue: bid, tokenSize: 16),
                  const SizedBox(width: 8),
                ],
                // Tricks won
                if (widget.gameState.phase == GamePhase.playing)
                  _buildStatBadge(
                    icon: Icons.emoji_events_rounded,
                    label: '${player.tricksWon}',
                    color: Colors.greenAccent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenCards(Player player, int playerIndex) {
    final cardCount = player.hand.length;

    return Stack(
      children: List.generate(cardCount.clamp(0, 5), (cardIndex) {
        return Transform.translate(
          offset: Offset(cardIndex * 15.0, cardIndex * 2.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: SlideTransition(
              position: _cardAnimations[playerIndex % _cardAnimations.length],
              child: const CardWidget(
                card: null,
                width: 60,
                height: 90,
                faceUp: false,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCenterTable() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.green.shade700.withOpacity(0.3),
            Colors.green.shade800.withOpacity(0.5),
            Colors.green.shade900.withOpacity(0.7),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.amber.withOpacity(0.7)),
        ),
        child: Stack(
          children: [
            // Inner decorative circles
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Content
            widget.gameState.currentTrick.isNotEmpty
                ? _buildCurrentTrick()
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(0.3),
                            Colors.amber.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.casino_rounded,
                        size: 70,
                        color: Colors.amber.withOpacity(0.6),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTrick() {
    final trickSize = widget.gameState.currentTrick.length;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...widget.gameState.currentTrick.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            // Disposer les cartes en éventail centré
            final angle = (index - (trickSize - 1) / 2) * 0.15;
            final offsetX = (index - (trickSize - 1) / 2) * 25.0;
            final offsetY = (index - (trickSize - 1) / 2) * 10.0;

            return Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Transform.rotate(
                angle: angle,
                child: AnimatedCard(
                  card: card,
                  delay: Duration(milliseconds: index * 200),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final game_card.Card card;
  final Duration delay;

  const AnimatedCard({
    super.key,
    required this.card,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CardWidget(card: widget.card, width: 80, height: 120),
          ),
        );
      },
    );
  }
}
