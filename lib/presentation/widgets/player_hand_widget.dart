import 'package:flutter/material.dart';
import '../../domain/entities/card.dart' as game_card;
import 'card_widget.dart';
import 'excuse_value_dialog.dart';

class PlayerHandWidget extends StatefulWidget {
  final List<game_card.Card> cards;
  final void Function(game_card.Card) onCardTap;
  final bool isPlayerTurn;

  const PlayerHandWidget({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.isPlayerTurn = false,
  });

  @override
  State<PlayerHandWidget> createState() => _PlayerHandWidgetState();
}

class _PlayerHandWidgetState extends State<PlayerHandWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  game_card.Card? _selectedCard;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isPlayerTurn) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayerHandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlayerTurn && !oldWidget.isPlayerTurn) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isPlayerTurn && oldWidget.isPlayerTurn) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleCardTap(game_card.Card card) async {
    if (!widget.isPlayerTurn) return;

    setState(() {
      _selectedCard = card;
    });

    // Si c'est l'Excuse, demander la valeur (0 ou 22)
    if (card.isExcuse) {
      final chosenValue = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ExcuseValueDialog(),
      );

      if (chosenValue != null) {
        final cardWithValue = game_card.Card(
          suit: card.suit,
          rank: card.rank,
          value: card.value,
          excuseValue: chosenValue,
        );
        widget.onCardTap(cardWithValue);
      } else {
        setState(() {
          _selectedCard = null;
        });
        return;
      }
    } else {
      widget.onCardTap(card);
    }

    setState(() {
      _selectedCard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedCards = _sortCards(widget.cards);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade900.withOpacity(0.7),
                Colors.deepPurple.shade800.withOpacity(0.85),
                Colors.black.withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              width: 2.5,
              color: widget.isPlayerTurn
                  ? Colors.cyanAccent.withOpacity(_glowAnimation.value * 0.7)
                  : Colors.amber.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, -8),
              ),
              if (widget.isPlayerTurn)
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(
                    _glowAnimation.value * 0.7,
                  ),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: Column(
            children: [
              // Header with player turn indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isPlayerTurn
                        ? [
                            Colors.cyan.shade700.withOpacity(0.6),
                            Colors.blue.shade900.withOpacity(0.4),
                          ]
                        : [
                            Colors.deepPurple.shade800.withOpacity(0.4),
                            Colors.deepPurple.shade900.withOpacity(0.2),
                          ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isPlayerTurn) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(
                            _glowAnimation.value * 0.3,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.touch_app_rounded,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.style_rounded,
                      color: widget.isPlayerTurn
                          ? Colors.cyanAccent
                          : Colors.amber.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isPlayerTurn
                          ? 'À votre tour!'
                          : 'Votre main (${widget.cards.length})',
                      style: TextStyle(
                        fontSize: 17,
                        color: widget.isPlayerTurn
                            ? Colors.cyanAccent
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.isPlayerTurn) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(
                            _glowAnimation.value * 0.3,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.touch_app_rounded,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Cards area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: sortedCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.style_outlined,
                                color: Colors.white24,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Aucune carte',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildHandCards(sortedCards),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildHandCards(List<game_card.Card> sortedCards) {
    return sortedCards.asMap().entries.map((entry) {
      final index = entry.key;
      final card = entry.value;
      final isSelected = _selectedCard == card;

      return Container(
        margin: EdgeInsets.only(right: index < sortedCards.length - 1 ? 6 : 0),
        child: GestureDetector(
          onTap: () => _handleCardTap(card),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            margin: EdgeInsets.only(top: isSelected ? 0.0 : 15.0),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.15 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: Colors.cyanAccent, width: 3)
                      : Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.8),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CardWidget(card: card, width: 85, height: 128),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<game_card.Card> _sortCards(List<game_card.Card> cards) {
    // Sort cards: trumps first (by descending value), then ordinary cards by suit
    final trumps = cards
        .where((card) => card.isTrump || card.isExcuse)
        .toList();
    final ordinary = cards
        .where((card) => !card.isTrump && !card.isExcuse)
        .toList();

    // Sort trumps by descending value
    trumps.sort((a, b) => b.value.compareTo(a.value));

    // Sort ordinary cards by suit then value
    ordinary.sort((a, b) {
      final suitComparison = a.suit.index.compareTo(b.suit.index);
      if (suitComparison != 0) return suitComparison;
      return b.value.compareTo(a.value);
    });

    return [...trumps, ...ordinary];
  }
}

// Alias for compatibility with existing code
class PlayerHand extends PlayerHandWidget {
  const PlayerHand({super.key, required super.cards, required super.onCardTap});
}
