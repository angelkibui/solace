import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'solace_button.dart';

/// Card for a community Circle — used in the Circles list/grid (Part I)
/// and could be reused on Home for "Trending Circles".
class CircleCard extends StatelessWidget {
  final String title;
  final String description;
  final int memberCount;
  final String? imageUrl;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback? onJoinToggle;

  const CircleCard({
    super.key,
    required this.title,
    required this.description,
    this.memberCount = 0,
    this.imageUrl,
    this.isJoined = false,
    this.onTap,
    this.onJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: imageUrl == null
                      ? Container(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 32),
                        )
                      : CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('$memberCount members', style: AppTextStyles.caption),
                  const Spacer(),
                  SolaceButton(
                    label: isJoined ? 'Leave' : 'Join',
                    variant: isJoined ? SolaceButtonVariant.outline : SolaceButtonVariant.primary,
                    height: 32,
                    onPressed: onJoinToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
