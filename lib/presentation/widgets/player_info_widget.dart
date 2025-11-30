import 'package:flutter/material.dart';

import '../../domain/entities/player.dart';
import 'bid_token_widget.dart';

class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;

  const PlayerInfoWidget({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.blue.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.blue : Colors.white30,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${player.score} points',
            style: TextStyle(
              fontSize: 14,
              color: player.score <= 3 ? Colors.red : Colors.lightGreenAccent,
            ),
          ),
          if (player.currentBid > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerBidToken(bidValue: player.currentBid, tokenSize: 20),
                const SizedBox(width: 8),
                Text(
                  'Plis: ${player.tricksWon}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
