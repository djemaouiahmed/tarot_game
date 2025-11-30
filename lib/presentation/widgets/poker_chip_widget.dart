import 'package:flutter/material.dart';

class PokerChip extends StatefulWidget {
  final int value;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const PokerChip({
    super.key,
    required this.value,
    this.isSelected = false,
    this.onTap,
    this.size = 60.0,
  });

  @override
  State<PokerChip> createState() => _PokerChipState();
}

class _PokerChipState extends State<PokerChip> {
  bool _isHovered = false;

  Color _getChipColor() {
    if (widget.value == 0) return Colors.grey;
    if (widget.value == 1) return Colors.red;
    if (widget.value == 2) return Colors.blue;
    if (widget.value == 3) return Colors.green;
    if (widget.value == 4) return Colors.purple;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor();
    final isInteractive = widget.onTap != null;
    final isActive = _isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) {
        if (isInteractive) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (isInteractive) {
          setState(() => _isHovered = false);
        }
      },
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedSlide(
            offset: Offset(0, _isHovered ? -0.1 : 0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    chipColor.withOpacity(0.8),
                    chipColor,
                    chipColor.withOpacity(0.6),
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
                border: Border.all(
                  color: isActive ? Colors.amber : Colors.white,
                  width: isActive ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: _isHovered
                        ? 15.0
                        : (widget.isSelected ? 12.0 : 6.0),
                    spreadRadius: _isHovered
                        ? 4.0
                        : (widget.isSelected ? 3.0 : 1.0),
                    offset: Offset(
                      0,
                      _isHovered ? 6.0 : (widget.isSelected ? 4.0 : 2.0),
                    ),
                  ),
                  BoxShadow(
                    color: isActive
                        ? Colors.amber.withOpacity(0.6)
                        : Colors.amber.withOpacity(0.0),
                    blurRadius: 15.0,
                    spreadRadius: 3.0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Cercle intérieur
                  Center(
                    child: Container(
                      width: widget.size * 0.7,
                      height: widget.size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.value}',
                          style: TextStyle(
                            fontSize: widget.size * 0.35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Motifs décoratifs
                  Positioned(
                    top: widget.size * 0.15,
                    left: widget.size * 0.15,
                    child: Container(
                      width: widget.size * 0.12,
                      height: widget.size * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.15,
                    right: widget.size * 0.15,
                    child: Container(
                      width: widget.size * 0.12,
                      height: widget.size * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
