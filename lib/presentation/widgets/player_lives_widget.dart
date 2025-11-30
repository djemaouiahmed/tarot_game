import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';

/// Widget to display player lives (ordinary cards) as progress bar
class PlayerLivesWidget extends StatelessWidget {
  final Player player;
  final bool isCompact;
  final bool showLabel;

  const PlayerLivesWidget({
    super.key,
    required this.player,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final livesCount = player.ordinaryCards.length;
    final maxLives = 14; // Maximum de cartes ordinaires
    final percentage = livesCount / maxLives;

    // Déterminer la couleur selon le pourcentage de vies
    Color getLifeColor() {
      if (percentage > 0.6) return Colors.greenAccent;
      if (percentage > 0.3) return Colors.orangeAccent;
      return Colors.redAccent;
    }

    if (isCompact) {
      // Version compacte : barre de progression horizontale
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Text(
              '$livesCount/$maxLives',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: getLifeColor(),
              ),
            ),
          const SizedBox(height: 2),
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [getLifeColor(), getLifeColor().withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: getLifeColor().withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Full version: vertical progress bar with icons
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers, color: getLifeColor(), size: 20),
            const SizedBox(width: 8),
            Text(
              '$livesCount / $maxLives Vies',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: getLifeColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [getLifeColor(), getLifeColor().withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: getLifeColor().withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
