import 'package:flutter/material.dart';

class StarRatingBar extends StatelessWidget {
  final int rating; // Da 0 a 5
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final double spacing;
  final Color? color;
  final Color? unselectedColor;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 22,
    this.spacing = 3,
    this.color,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFFE5A93C);
    final inactiveColor = unselectedColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        final starIcon = Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFilled ? activeColor : inactiveColor,
          size: size,
        );

        if (onRatingChanged == null) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: starIcon,
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () {
            // Se clicca sulla stessa stella e il rating è 1, o per azzerare se desiderato:
            // Permettiamo di impostare il nuovo punteggio
            onRatingChanged!(starValue);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: starIcon,
          ),
        );
      }),
    );
  }
}
