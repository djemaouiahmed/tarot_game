import 'package:flutter/material.dart';

/// Displays a poker chip token representing a bid
class BidTokenWidget extends StatelessWidget {
  final int value;
  final double size;
  final Color? color;

  const BidTokenWidget({
    super.key,
    required this.value,
    this.size = 24,
    this.color,
  });

  Color _getTokenColor() {
    if (color != null) return color!;

    // Standard poker chip colors based on value
    if (value == 0) return Colors.grey;
    if (value == 1) return Colors.white;
    if (value == 2) return Colors.red;
    if (value == 3) return Colors.blue;
    if (value == 4) return Colors.green;
    if (value >= 5) return Colors.black;

    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getTokenColor();
    final textColor = chipColor == Colors.white || chipColor == Colors.grey
        ? Colors.black
        : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            chipColor.withOpacity(0.9),
            chipColor,
            chipColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(color: Colors.white, width: size * 0.08),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Outer ring pattern
          Center(
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor.withOpacity(0.3),
                  width: size * 0.03,
                ),
              ),
            ),
          ),
          // Inner circle with value
          Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chipColor.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    color: textColor,
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays multiple bid tokens stacked vertically
class BidTokenStack extends StatelessWidget {
  final int bidValue;
  final double tokenSize;
  final Color? tokenColor;
  final bool compact;

  const BidTokenStack({
    super.key,
    required this.bidValue,
    this.tokenSize = 24,
    this.tokenColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bidValue == 0) {
      return const SizedBox.shrink();
    }

    final stackCount = bidValue;
    final stackOffset = compact ? tokenSize * 0.15 : tokenSize * 0.25;

    return SizedBox(
      width: tokenSize,
      height: tokenSize + (stackOffset * (stackCount - 1)),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(stackCount, (index) {
          final position = (stackCount - 1 - index) * stackOffset;
          return Positioned(
            bottom: position,
            child: BidTokenWidget(
              value: bidValue,
              size: tokenSize,
              color: tokenColor,
            ),
          );
        }),
      ),
    );
  }
}

/// Displays bid token next to player's position
class PlayerBidToken extends StatelessWidget {
  final int? bidValue;
  final double tokenSize;
  final String? playerName;

  const PlayerBidToken({
    super.key,
    this.bidValue,
    this.tokenSize = 22,
    this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    if (bidValue == null || bidValue == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BidTokenStack(
            bidValue: bidValue!,
            tokenSize: tokenSize,
            compact: true,
          ),
          if (playerName != null) ...[
            const SizedBox(width: 6),
            Text(
              playerName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
