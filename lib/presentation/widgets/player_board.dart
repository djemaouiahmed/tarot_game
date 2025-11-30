import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/card.dart' as game_card;
import '../../core/utils/responsive_utils.dart';
import 'card_widget.dart';
import 'bid_token_widget.dart';

enum PlayerOrientation { left, top, right }

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

    // For 4 players: position bots on left, top, right
    // For 3 players: position bots on left and right
    // For 2 players: position bot on top

    return Stack(
      children: [
        // Center table (playing area)
        Center(child: _buildCenterTable()),

        // Position bots based on player count
        if (botPlayers.isNotEmpty)
          ..._buildPositionedPlayers(context, botPlayers),
      ],
    );
  }

  List<Widget> _buildPositionedPlayers(
    BuildContext context,
    List<Player> botPlayers,
  ) {
    final List<Widget> positionedPlayers = [];
    final screenWidth = ResponsiveUtils.getAvailableWidth(context);
    final screenHeight = ResponsiveUtils.getAvailableHeight(context);
    final spacing = ResponsiveUtils.getHorizontalSpacing(context);

    // Responsive sizing
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final playerCardWidth = isSmall
        ? 140.0
        : ResponsiveUtils.valueByScreen(
            context: context,
            mobile: 160.0,
            tablet: 180.0,
            desktop: 200.0,
          );

    if (botPlayers.length >= 3) {
      // 4-player mode: Left, Top, Right
      // Left player (Bot 1)
      positionedPlayers.add(
        Positioned(
          left: spacing * 2,
          top: screenHeight * 0.35,
          child: _buildOpponentPlayer(
            botPlayers[0],
            orientation: PlayerOrientation.left,
            width: playerCardWidth,
          ),
        ),
      );

      // Top player (Bot 2)
      positionedPlayers.add(
        Positioned(
          top: spacing * 3,
          left: (screenWidth - playerCardWidth) / 2,
          child: _buildOpponentPlayer(
            botPlayers[1],
            orientation: PlayerOrientation.top,
            width: playerCardWidth,
          ),
        ),
      );

      // Right player (Bot 3)
      positionedPlayers.add(
        Positioned(
          right: spacing * 2,
          top: screenHeight * 0.35,
          child: _buildOpponentPlayer(
            botPlayers[2],
            orientation: PlayerOrientation.right,
            width: playerCardWidth,
          ),
        ),
      );
    } else if (botPlayers.length == 2) {
      // 3-player mode: Left and Right
      positionedPlayers.add(
        Positioned(
          left: spacing * 2,
          top: screenHeight * 0.35,
          child: _buildOpponentPlayer(
            botPlayers[0],
            orientation: PlayerOrientation.left,
            width: playerCardWidth,
          ),
        ),
      );

      positionedPlayers.add(
        Positioned(
          right: spacing * 2,
          top: screenHeight * 0.35,
          child: _buildOpponentPlayer(
            botPlayers[1],
            orientation: PlayerOrientation.right,
            width: playerCardWidth,
          ),
        ),
      );
    } else if (botPlayers.length == 1) {
      // 2-player mode: Top
      positionedPlayers.add(
        Positioned(
          top: spacing * 3,
          left: (screenWidth - playerCardWidth) / 2,
          child: _buildOpponentPlayer(
            botPlayers[0],
            orientation: PlayerOrientation.top,
            width: playerCardWidth,
          ),
        ),
      );
    }

    return positionedPlayers;
  }

  Widget _buildOpponentPlayer(
    Player player, {
    required PlayerOrientation orientation,
    required double width,
  }) {
    final playerIndex = widget.gameState.players.indexOf(player);
    final isCurrentTurn = widget.gameState.currentPlayer.id == player.id;
    final bidIndex = widget.gameState.players.indexOf(player);
    final hasBid = bidIndex < widget.gameState.bids.length;
    final bid = hasBid ? widget.gameState.bids[bidIndex] : null;

    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final cardWidth = isSmall
        ? 50.0
        : ResponsiveUtils.valueByScreen(
            context: context,
            mobile: 55.0,
            tablet: 65.0,
            desktop: 75.0,
          );
    final cardHeight = isSmall
        ? 75.0
        : ResponsiveUtils.valueByScreen(
            context: context,
            mobile: 82.5,
            tablet: 97.5,
            desktop: 112.5,
          );

    return Container(
      width: width,
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalSpacing(context)),
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
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveSize(context, 16),
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with modern badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 1.5,
              vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrentTurn
                    ? [Colors.cyanAccent.shade400, Colors.blue.shade600]
                    : [Colors.amber.shade600, Colors.orange.shade800],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveSize(context, 20),
              ),
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
                Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context, 16),
                ),
                SizedBox(
                  width: ResponsiveUtils.getHorizontalSpacing(context) * 0.75,
                ),
                Text(
                  player.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.getFontSize(context, 13),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),

          // Cards with glow effect
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getHorizontalSpacing(context),
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveSize(context, 12),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: _buildHiddenCards(
              player,
              playerIndex,
              cardWidth,
              cardHeight,
            ),
          ),

          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.25),

          // Stats row with modern design
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalSpacing(context),
              vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveSize(context, 10),
              ),
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
                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                // Bid token
                if (bid != null && bid > 0) ...[
                  PlayerBidToken(
                    bidValue: bid,
                    tokenSize: ResponsiveUtils.getIconSize(context, 16),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getHorizontalSpacing(context),
                  ),
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
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 0.75,
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.375,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveSize(context, 8),
        ),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getIconSize(context, 14),
          ),
          SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveUtils.getFontSize(context, 12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenCards(
    Player player,
    int playerIndex,
    double cardWidth,
    double cardHeight,
  ) {
    final cardCount = player.hand.length;
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final cardOffset = isSmall ? 12.0 : 15.0;

    return Stack(
      children: List.generate(cardCount.clamp(0, 5), (cardIndex) {
        return Transform.translate(
          offset: Offset(cardIndex * cardOffset, cardIndex * 2.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveSize(context, 8),
              ),
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
              child: CardWidget(
                card: null,
                width: cardWidth,
                height: cardHeight,
                faceUp: false,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCenterTable() {
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final tableSize = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: isSmall ? 200.0 : 280.0,
      tablet: 350.0,
      desktop: 400.0,
    );

    return Container(
      width: tableSize,
      height: tableSize,
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
                width: tableSize * 0.75,
                height: tableSize * 0.75,
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
                width: tableSize * 0.5,
                height: tableSize * 0.5,
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
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getHorizontalSpacing(context) * 2.5,
                      ),
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
                        size: ResponsiveUtils.getIconSize(context, 70),
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
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final cardSpacing = isSmall ? 20.0 : 25.0;
    final cardVerticalOffset = isSmall ? 8.0 : 10.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...widget.gameState.currentTrick.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            // Disposer les cartes en éventail centré
            final angle = (index - (trickSize - 1) / 2) * 0.15;
            final offsetX = (index - (trickSize - 1) / 2) * cardSpacing;
            final offsetY = (index - (trickSize - 1) / 2) * cardVerticalOffset;

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
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final cardWidth = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: isSmall ? 65.0 : 75.0,
      tablet: 90.0,
      desktop: 100.0,
    );
    final cardHeight = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: isSmall ? 97.5 : 112.5,
      tablet: 135.0,
      desktop: 150.0,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CardWidget(
              card: widget.card,
              width: cardWidth,
              height: cardHeight,
            ),
          ),
        );
      },
    );
  }
}
