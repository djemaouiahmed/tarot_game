import 'package:flutter/material.dart';

import '../../domain/entities/game_state.dart';
import 'card_widget.dart';

class GameBoard extends StatefulWidget {
  final GameState gameState;

  const GameBoard({super.key, required this.gameState});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated glow particles in background (heavily optimized)
        ...List.generate(2, (index) {
          final radius = 0.35;
          return Positioned(
            left:
                MediaQuery.of(context).size.width *
                (0.5 + radius * (index % 2 == 0 ? 1 : -1) * (index / 2)),
            top:
                MediaQuery.of(context).size.height *
                (0.3 + radius * (index % 3 == 0 ? 1 : -1) * ((2 - index) / 2)),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity:
                        0.18 *
                        _pulseAnimation.value *
                        ((index % 2 == 0) ? 1 : 0.8),
                    child: Container(
                      width: 90 + (index % 2) * 25,
                      height: 90 + (index % 2) * 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            index % 2 == 0 ? Colors.amber : Colors.cyanAccent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),

        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Informations du tour
              _buildRoundInfo(),

              const SizedBox(height: 12),

              // Pli en cours
              if (widget.gameState.currentTrick.isNotEmpty)
                Flexible(child: _buildCurrentTrick()),

              if (widget.gameState.currentTrick.isNotEmpty)
                const SizedBox(height: 12),

              // Information sur le joueur courant
              _buildCurrentPlayerInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoundInfo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade800.withOpacity(0.85),
                Colors.deepPurple.shade900.withOpacity(0.95),
                Colors.black.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amber.withOpacity(0.6 * _pulseAnimation.value),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.amber.withOpacity(0.2 * _pulseAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.amber.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.casino,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tour ${widget.gameState.currentRound}/5',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.gameState.cardsPerRound} carte${widget.gameState.cardsPerRound > 1 ? 's' : ''} par joueur',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.gameState.phase == GamePhase.bidding)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade500, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Phase de paris',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
              else if (widget.gameState.phase == GamePhase.playing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade500, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.style, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Phase de jeu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentTrick() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.deepPurple.shade900.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Pli en cours',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: widget.gameState.currentTrick.map((card) {
              return Transform.scale(
                scale: 1.05,
                child: CardWidget(card: card, width: 100, height: 170),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayerInfo() {
    final currentPlayer = widget.gameState.currentPlayer;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.withOpacity(0.3),
                Colors.blue.shade700.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.6 * _pulseAnimation.value),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(
                  0.3 * _pulseAnimation.value,
                ),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.gameState.phase == GamePhase.bidding
                    ? Icons.person
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                widget.gameState.phase == GamePhase.bidding
                    ? '${currentPlayer.name} doit parier'
                    : 'Tour de ${currentPlayer.name}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
