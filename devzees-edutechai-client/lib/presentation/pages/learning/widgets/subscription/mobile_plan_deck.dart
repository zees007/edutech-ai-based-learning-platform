import 'package:flutter/material.dart';

class MobilePlanDeck extends StatefulWidget {
  final List<Widget> cards;
  final int initialIndex;
  final double cardHeight;

  const MobilePlanDeck({
    super.key,
    required this.cards,
    this.initialIndex = 0,
    this.cardHeight = 750, // Increased to fit the Pro/Ultra card content
  });

  @override
  State<MobilePlanDeck> createState() => _MobilePlanDeckState();
}

class _MobilePlanDeckState extends State<MobilePlanDeck> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.85, // Shows 15% of the adjacent cards on the edges
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.cardHeight,
      child: PageView.builder(
        controller: _pageController,
        clipBehavior: Clip.none, // Allow cards' glowing shadows to extend beyond bounds
        itemCount: widget.cards.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0;
              if (_pageController.position.haveDimensions) {
                pageOffset = _pageController.page! - index;
              } else {
                pageOffset = widget.initialIndex.toDouble() - index;
              }

              // Calculate scale and opacity based on absolute distance from the center
              double absOffset = pageOffset.abs();
              
              // Scale interpolates smoothly from 1.0 (center) down to 0.85 (edges)
              double scale = (1 - (absOffset * 0.15)).clamp(0.85, 1.0);
              
              // Opacity interpolates smoothly from 1.0 (center) down to 0.5 (edges)
              double opacity = (1 - (absOffset * 0.5)).clamp(0.5, 1.0);

              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                ),
              );
            },
            child: widget.cards[index],
          );
        },
      ),
    );
  }
}
