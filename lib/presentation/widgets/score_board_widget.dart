import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import 'player_lives_widget.dart';

class ScoreBoard extends StatelessWidget {
  final GameState gameState;

  const ScoreBoard({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.9),
            Colors.deepPurple.shade900.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 10),

                // Players row (horizontal layout)
                Row(
                  children: gameState.players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    return Expanded(child: _buildPlayerCard(player, index));
                  }).toList(),
                ),
              ],
            ),
          ),

          // Burger menu button (top-left)
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700.withOpacity(0.95),
                        Colors.deepPurple.shade900.withOpacity(0.98),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: Colors.amber.shade300,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title with icon - shifted right to avoid menu overlap
        Row(
          children: [
            const SizedBox(width: 48), // Space for menu button
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.amber.shade600, Colors.amber.shade800],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tableau des Scores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        // Round badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.casino_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                'Tour ${gameState.currentRound}/5',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final isCurrentPlayer = player.id == gameState.currentPlayer.id;
    final hasBid = index < gameState.bids.length;
    final playerBid = hasBid ? gameState.bids[index] : null;
    final isHuman = player.type == PlayerType.human;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCurrentPlayer
              ? [
                  Colors.cyan.shade600.withOpacity(0.4),
                  Colors.blue.shade800.withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.cyanAccent.withOpacity(0.8)
              : Colors.white.withOpacity(0.2),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHuman ? Icons.person_rounded : Icons.smart_toy_rounded,
                color: isHuman ? Colors.amber.shade400 : Colors.grey.shade400,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrentPlayer
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getScoreColor(player.score).withOpacity(0.3),
                  _getScoreColor(player.score).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getScoreColor(player.score).withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: Text(
              '${player.score}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(player.score),
                shadows: [
                  Shadow(
                    color: _getScoreColor(player.score).withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Lives
          PlayerLivesWidget(player: player, isCompact: true, showLabel: false),

          // Bid and tricks info
          if (playerBid != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bid
                _buildStatChip(
                  icon: Icons.casino_outlined,
                  value: '$playerBid',
                  color: Colors.orange,
                ),
                const SizedBox(width: 6),
                // Tricks
                _buildStatChip(
                  icon: Icons.emoji_events_outlined,
                  value: '${player.tricksWon}',
                  color: playerBid == player.tricksWon
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score <= 0) return Colors.red.shade400;
    if (score <= 3) return Colors.orange.shade400;
    if (score <= 7) return Colors.yellow.shade600;
    return Colors.greenAccent;
  }
}
