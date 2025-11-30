import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import 'poker_chip_widget.dart';
import 'card_widget.dart';

class BidControls extends StatefulWidget {
  final GameState gameState;

  const BidControls({super.key, required this.gameState});

  @override
  State<BidControls> createState() => _BidControlsState();
}

class _BidControlsState extends State<BidControls> {
  bool _showHand = false;

  @override
  Widget build(BuildContext context) {
    final maxBid = widget.gameState.cardsPerRound;
    final humanPlayer = widget.gameState.players.firstWhere(
      (p) => p.type == PlayerType.human,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.withOpacity(0.3),
            Colors.deepPurple.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and show hand button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show Hand toggle button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showHand = !_showHand;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _showHand
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showHand ? Colors.amber : Colors.white38,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showHand ? Icons.visibility : Icons.visibility_off,
                          color: _showHand ? Colors.amber : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Show Hand',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _showHand ? Colors.amber : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  const Icon(Icons.casino, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Votre pari ?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Spacer to balance the layout
              const SizedBox(width: 100),
            ],
          ),

          // Hand preview (shown when toggle is active)
          if (_showHand) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: humanPlayer.hand.map((card) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CardWidget(card: card, width: 50, height: 75),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Poker chips horizontal layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(maxBid + 1, (index) {
                final bidValue = index;
                final isValid = _isValidBid(bidValue);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Opacity(
                    opacity: isValid ? 1.0 : 0.4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PokerChip(
                          value: bidValue,
                          isSelected: false,
                          size: 70,
                          onTap: isValid
                              ? () {
                                  context.read<GameBloc>().add(
                                    MakeBidEvent(bidValue),
                                  );
                                }
                              : null,
                        ),
                        if (!isValid)
                          Icon(
                            Icons.block,
                            color: Colors.red.withOpacity(0.8),
                            size: 35,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidBid(int bid) {
    // Calculate total of already made bids
    int totalBids = bid;
    for (final b in widget.gameState.bids) {
      totalBids += b;
    }

    // Check if this is the last player to bid
    final isLastPlayer =
        widget.gameState.bids.length == widget.gameState.players.length - 1;

    // Last player cannot bid so that total exactly equals number of cards
    // This prevents everyone from winning their bids
    if (isLastPlayer && totalBids == widget.gameState.cardsPerRound) {
      return false;
    }

    return true;
  }
}