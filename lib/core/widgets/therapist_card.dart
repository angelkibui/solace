import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'solace_button.dart';
import 'star_rating.dart';

/// Card used everywhere a therapist is listed: the directory (Part F),
/// home's "Recommended for you" rail, and the onboarding preview (Part C).
///
/// Takes plain fields rather than a `TherapistModel` on purpose — this is
/// a presentational widget, so it stays usable before/without the data
/// layer that Part F will add. [rating] is nullable: the Figma directory
/// preview doesn't show a star row at all, but Part L (Reviews) will want
/// one once real ratings exist — pass a rating to opt in.
class TherapistCard extends StatelessWidget {
  final String name;
  final String roleLabel;
  final List<String> traits;
  final String bio;
  final List<String> languages;
  final String rate;
  final String? imageUrl;
  final double? rating;
  final int reviewCount;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final IconData secondaryActionIcon;
  final VoidCallback? onSecondaryAction;

  const TherapistCard({
    super.key,
    required this.name,
    required this.roleLabel,
    this.traits = const [],
    this.bio = '',
    this.languages = const [],
    this.rate = '',
    this.imageUrl,
    this.rating,
    this.reviewCount = 0,
    this.onTap,
    this.onBook,
    this.secondaryActionIcon = Icons.bookmark_border_rounded,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: imageUrl == null
                          ? Container(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppColors.divider),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          roleLabel.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StarRating(rating: rating!, size: 14),
                              const SizedBox(width: 6),
                              Text('($reviewCount)', style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (traits.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: traits
                      .map((trait) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(trait, style: AppTextStyles.caption),
                          ))
                      .toList(),
                ),
              ],
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(bio, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              if (languages.isNotEmpty || rate.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (languages.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Languages', style: AppTextStyles.caption),
                            const SizedBox(height: 2),
                            Text(languages.join(', '), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    if (rate.isNotEmpty)
                      Text(
                        rate,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SolaceButton(label: 'Book Consultation', height: 44, onPressed: onBook),
                  ),
                  if (onSecondaryAction != null) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onSecondaryAction,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Icon(secondaryActionIcon, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}