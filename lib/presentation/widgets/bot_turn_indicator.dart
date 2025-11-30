import 'package:flutter/material.dart';
import 'dart:async';

class BotTurnIndicator extends StatefulWidget {
  final String playerName;
  final String action;
  final Duration delay;
  final VoidCallback onComplete;

  const BotTurnIndicator({
    super.key,
    required this.playerName,
    required this.action,
    required this.delay,
    required this.onComplete,
  });

  @override
  State<BotTurnIndicator> createState() => _BotTurnIndicatorState();
}

class _BotTurnIndicatorState extends State<BotTurnIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.delay,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _startAnimation();
  }

  void _startAnimation() {
    _pulseController.repeat(reverse: true);
    _progressController.forward();

    _delayTimer = Timer(widget.delay, () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicateur de joueur avec animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.3),
                    border: Border.all(color: Colors.orange, width: 3),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Nom du joueur
          Text(
            widget.playerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Action en cours
          Text(
            widget.action,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 20),

          // Barre de progression
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Texte de progression
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final remaining =
                  widget.delay.inMilliseconds * (1 - _progressAnimation.value);
              final seconds = (remaining / 1000).ceil();
              return Text(
                '$seconds s',
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BotActionOverlay extends StatelessWidget {
  final String playerName;
  final String action;
  final Duration delay;
  final VoidCallback onComplete;

  const BotActionOverlay({
    super.key,
    required this.playerName,
    required this.action,
    required this.delay,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
              ),
            ),
            child: BotTurnIndicator(
              playerName: playerName,
              action: action,
              delay: delay,
              onComplete: onComplete,
            ),
          ),
        ),
      ),
    );
  }
}
