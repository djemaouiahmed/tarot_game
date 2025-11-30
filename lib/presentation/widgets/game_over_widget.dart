import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/player.dart';

/// Widget d'animation de fin de partie
class GameOverWidget extends StatefulWidget {
  final Player winner;
  final List<Player> allPlayers;
  final VoidCallback onNewGame;

  const GameOverWidget({
    super.key,
    required this.winner,
    required this.allPlayers,
    required this.onNewGame,
  });

  @override
  State<GameOverWidget> createState() => _GameOverWidgetState();
}

class _GameOverWidgetState extends State<GameOverWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade900, Colors.blue.shade900],
        ),
      ),
      child: Stack(
        children: [
          // Confettis
          ...List.generate(30, (index) => _buildConfetti(index)),

          // Contenu principal
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône de trophée
                  const Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),

                  // Nom du gagnant
                  Text(
                    '${widget.winner.name} gagne !',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Score final
                  Text(
                    'Score: ${widget.winner.score}',
                    style: const TextStyle(fontSize: 28, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),

                  // Classement
                  _buildLeaderboard(),
                  const SizedBox(height: 48),

                  // Bouton nouvelle partie
                  ElevatedButton(
                    onPressed: widget.onNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Nouvelle Partie'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final delay = random.nextDouble() * 2;
    final color = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ][random.nextInt(6)];

    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final progress = (_confettiController.value + delay) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Positioned(
          left: startX * screenWidth,
          top: progress * screenHeight,
          child: Transform.rotate(
            angle: progress * 4 * math.pi,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboard() {
    final sortedPlayers = List<Player>.from(widget.allPlayers)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Classement Final',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final medal = index == 0
                ? '🥇'
                : index == 1
                ? '🥈'
                : index == 2
                ? '🥉'
                : '${index + 1}.';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      medal,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: player == widget.winner
                            ? Colors.amber
                            : Colors.white70,
                        fontWeight: player == widget.winner
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${player.score} pts',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
