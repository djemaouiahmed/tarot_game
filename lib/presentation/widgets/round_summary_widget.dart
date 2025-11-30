import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';

class RoundSummaryWidget extends StatefulWidget {
  final List<Player> players;
  final List<int> bids;
  final int roundNumber;
  final VoidCallback onDismiss;

  const RoundSummaryWidget({
    super.key,
    required this.players,
    required this.bids,
    required this.roundNumber,
    required this.onDismiss,
  });

  @override
  State<RoundSummaryWidget> createState() => _RoundSummaryWidgetState();
}

class _RoundSummaryWidgetState extends State<RoundSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto dismiss après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade800,
                    Colors.deepPurple.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.amber, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tour ${widget.roundNumber} Terminé',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Résultats des joueurs
                  ...widget.players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final bid = index < widget.bids.length
                        ? widget.bids[index]
                        : 0;
                    final tricks = player.tricksWon;
                    final diff = (tricks - bid).abs();
                    final success = tricks == bid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: success
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: success ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icône joueur
                          Icon(
                            player.type == PlayerType.human
                                ? Icons.person
                                : Icons.smart_toy,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 12),

                          // Nom
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Pari vs Résultat
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Pari: $bid',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Plis: $tricks',
                                  style: const TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Résultat
                          if (success)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-$diff ❤️',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
