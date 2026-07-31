import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

/// Bottom navigation shell used by the main app scaffold once Home,
/// Therapists, Circles, Chat, and Profile all exist. Matches the Figma
/// reference's active-tab treatment: a rounded green pill behind the
/// selected icon+label instead of a plain color change.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.psychology_alt_rounded, 'Therapists'),
    _NavItem(Icons.groups_rounded, 'Circles'),
    _NavItem(Icons.chat_bubble_rounded, 'Chat'),
    _NavItem(Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
