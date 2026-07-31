import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows a 1–5 star rating. Set [readOnly] to false and pass
/// [onRatingChanged] to use this as an input (Part L review screen);
/// leave it read-only (default) to just display a rating (TherapistCard).
class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool readOnly;
  final ValueChanged<int>? onRatingChanged;
  final bool showValue;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.readOnly = true,
    this.onRatingChanged,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (index) {
          final starValue = index + 1;
          final isFilled = starValue <= rating.round();
          final icon = Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: AppColors.warning,
          );

          if (readOnly) return icon;

          return GestureDetector(
            onTap: () => onRatingChanged?.call(starValue),
            child: icon,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(rating.toStringAsFixed(1), style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}
