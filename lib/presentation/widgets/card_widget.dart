import 'package:flutter/material.dart' hide Card;
import 'package:tarot_africain/core/constants/card_assets.dart';

import '../../domain/entities/card.dart';
import '../../core/utils/responsive_utils.dart';

// Widget représentant une carte de tarot avec animations et effets visuels
// Supporte les cartes face visible/cachée, sélection, et interactions hover
// Responsive: tailles adaptées selon l'écran (téléphone/tablette)
class CardWidget extends StatefulWidget {
  final Card? card; // Carte à afficher (null pour carte cachée)
  final bool faceUp; // Afficher face visible ou dos de la carte
  final bool isSelected; // Carte actuellement sélectionnée
  final VoidCallback? onTap; // Callback lors du tap
  final double? width; // Largeur de la carte (null = responsive)
  final double? height; // Hauteur de la carte (null = responsive)

  const CardWidget({
    super.key,
    this.card, // Peut être null pour les cartes face cachée
    this.faceUp = true,
    this.isSelected = false,
    this.onTap,
    this.width, // Par défaut null pour activer responsive
    this.height, // Par défaut null pour activer responsive
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Utiliser les dimensions responsive si width/height non spécifiées
    final cardWidth = widget.width ?? ResponsiveUtils.getCardWidth(context);
    final cardHeight = widget.height ?? ResponsiveUtils.getCardHeight(context);

    // RepaintBoundary pour isoler les repaints et optimiser les performances
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          // AnimatedContainer pour les transitions fluides lors de la sélection
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: cardWidth,
            height: cardHeight,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            transform: Matrix4.identity()
              ..translate(
                0.0,
                widget.isSelected ? -25.0 : (_isHovered ? -15.0 : 0.0),
              )
              ..scale(widget.isSelected ? 1.05 : (_isHovered ? 1.05 : 1.0)),
            child: Stack(
              children: [
                // Ombres simplifiées pour de meilleures performances
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: widget.isSelected || _isHovered
                        ? [
                            // Ombre colorée pour la carte sélectionnée/hoverée
                            BoxShadow(
                              color: widget.isSelected
                                  ? Colors.amber.withOpacity(0.6)
                                  : Colors.cyanAccent.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Image de la carte (face visible ou dos)
                        widget.card != null && widget.faceUp
                            ? Image.asset(
                                CardAssets.getCardPath(widget.card!),
                                width: cardWidth,
                                height: cardHeight,
                                fit: BoxFit.fill,
                                // Cache pour optimiser le chargement
                                cacheWidth: (cardWidth * 2).toInt(),
                                cacheHeight: (cardHeight * 2).toInt(),
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackCard(
                                    cardWidth,
                                    cardHeight,
                                  );
                                },
                              )
                            : Image.asset(
                                CardAssets.cardBack,
                                width: cardWidth,
                                height: cardHeight,
                                fit: BoxFit.fill,
                                cacheWidth: (cardWidth * 2).toInt(),
                                cacheHeight: (cardHeight * 2).toInt(),
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildBackCard(cardWidth, cardHeight);
                                },
                              ),

                        // Effet de brillance au survol
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.2),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Bordure premium pour la carte sélectionnée ou hoverée
                if (widget.isSelected || _isHovered)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.isSelected
                            ? Colors.amber
                            : Colors.cyanAccent,
                        width: _isHovered ? 3.5 : 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.isSelected
                                      ? Colors.amber
                                      : Colors.cyanAccent)
                                  .withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget de repli si l'image de la carte ne charge pas
  Widget _buildFallbackCard(double cardWidth, double cardHeight) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          widget.card != null ? _getCardLabel() : '?',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // Widget pour le dos de la carte
  Widget _buildBackCard(double cardWidth, double cardHeight) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.style, color: Colors.white, size: 30),
      ),
    );
  }

  // Génère le libellé de la carte pour l'affichage de repli
  String _getCardLabel() {
    if (widget.card == null) return '?';
    if (widget.card!.isExcuse) return 'Excuse';
    if (widget.card!.isTrump) return 'A${widget.card!.value}';
    return '${_getRankLabel()}${_getSuitSymbol()}';
  }

  // Convertit le rang de la carte en libellé (V=Valet, C=Cavalier, D=Dame, R=Roi)
  String _getRankLabel() {
    if (widget.card == null) return '?';
    switch (widget.card!.rank) {
      case CardRank.jack:
        return 'V';
      case CardRank.knight:
        return 'C';
      case CardRank.queen:
        return 'D';
      case CardRank.king:
        return 'R';
      case CardRank.ace:
        return 'A';
      default:
        return '${widget.card!.value}';
    }
  }

  // Retourne le symbole Unicode de la couleur de la carte
  String _getSuitSymbol() {
    if (widget.card == null) return '';
    switch (widget.card!.suit) {
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.hearts:
        return '♥';
      default:
        return '';
    }
  }
}

// Widget affichant une main complète de cartes en ligne horizontale
// Permet le défilement si trop de cartes
class PlayerHand extends StatelessWidget {
  final List<Card> cards;
  final void Function(Card) onCardTap;
  final bool faceUp;

  const PlayerHand({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.faceUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: EdgeInsets.all(8),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards.map((card) {
              return CardWidget(
                card: card,
                faceUp: faceUp,
                onTap: () => onCardTap(card),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Widget affichant un paquet de cartes ordinaires collectées par un joueur
// Utilisé pour montrer les cartes gagnées pendant la partie
class OrdinaryCardsDeck extends StatelessWidget {
  final List<Card> cards;
  final String playerName;

  const OrdinaryCardsDeck({
    super.key,
    required this.cards,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(playerName, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: cards.take(5).map((card) {
              return CardWidget(card: card, width: 40, height: 60);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
