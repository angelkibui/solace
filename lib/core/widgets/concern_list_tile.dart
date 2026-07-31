import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The large selectable list card used on the "What's on your mind
/// today?" screen — icon in a tinted circle, title, description, and a
/// checkmark that appears when selected. This is what the Figma design
/// actually shows for concern selection (not small pill chips).
class ConcernListTile extends StatelessWidget {
  final ConcernOption concern;
  final bool isSelected;
  final int tintIndex;
  final VoidCallback? onTap;

  const ConcernListTile({
    super.key,
    required this.concern,
    required this.tintIndex,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.iconTints[tintIndex % AppColors.iconTints.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: tint[0], borderRadius: BorderRadius.circular(14)),
                  child: Icon(concern.icon, color: tint[1], size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(concern.title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 3),
                      Text(concern.description, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.divider,
                        width: 1.4),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
