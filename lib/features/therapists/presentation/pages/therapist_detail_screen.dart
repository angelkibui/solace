import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../data/models/therapist_model.dart';

class TherapistDetailScreen extends StatelessWidget {
  final TherapistModel therapist;
  final VoidCallback onBook;

  const TherapistDetailScreen({
    super.key,
    required this.therapist,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Professional Profile'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHero(therapist: therapist),
                        const SizedBox(height: 18),
                        _TrustStrip(therapist: therapist),
                        const SizedBox(height: 24),
                        Text('About', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 8),
                        Text(
                          therapist.bio,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        Text('Specialties', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: therapist.specialties
                              .map((specialty) => Chip(label: Text(specialty)))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        _InfoCard(therapist: therapist),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Session rate', style: AppTextStyles.caption),
                          Text(
                            '${NumberFormat.decimalPattern().format(therapist.rate)} RWF / hr',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SolaceButton(
                      label: 'Book Consultation',
                      icon: Icons.calendar_month_rounded,
                      onPressed: onBook,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final TherapistModel therapist;

  const _ProfileHero({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.info.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 92,
              height: 108,
              child: therapist.photoUrl.isEmpty
                  ? Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: therapist.photoUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person_rounded, size: 48),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(therapist.name, style: AppTextStyles.headingMedium),
                const SizedBox(height: 4),
                Text(
                  therapist.title.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StarRating(rating: therapist.rating, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${therapist.rating.toStringAsFixed(1)} · ${therapist.reviewCount} reviews',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        therapist.location,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  final TherapistModel therapist;

  const _TrustStrip({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _TrustItem(
            icon: Icons.verified_user_outlined,
            label: 'Verified',
          ),
        ),
        Expanded(
          child: _TrustItem(
            icon: Icons.translate_rounded,
            label: '${therapist.languages.length} languages',
          ),
        ),
        const Expanded(
          child: _TrustItem(icon: Icons.lock_outline_rounded, label: 'Private'),
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 5),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TherapistModel therapist;

  const _InfoCard({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.translate_rounded,
              label: 'Languages',
              value: therapist.languages.join(', '),
            ),
            const Divider(height: 28),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Gender',
              value: therapist.gender,
            ),
            const Divider(height: 28),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Availability',
              value: therapist.availability.isEmpty
                  ? 'Contact for availability'
                  : '${therapist.availability.length} upcoming slots',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
