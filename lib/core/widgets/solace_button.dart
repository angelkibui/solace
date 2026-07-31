import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// - [primary]: green, the app's main "do the thing" action color
///   (Book Consultation, Pay with MoMo, Enter Circle).
/// - [secondary]: navy, used for the onboarding hero CTA and other
///   dark high-emphasis actions.
/// - [outline]: bordered, low-emphasis actions.
enum SolaceButtonVariant { primary, secondary, outline }

/// The one button widget the whole app should use. Wraps
/// ElevatedButton/OutlinedButton so every screen gets consistent height,
/// radius, and a built-in loading spinner instead of each feature
/// reinventing "disable + show spinner" logic.
class SolaceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SolaceButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  /// Overrides the theme's default 52px minimum button height. Use this
  /// for compact inline placements (e.g. the Join/Leave button inside
  /// [CircleCard]) instead of nesting SolaceButton in a height-constrained
  /// SizedBox, which would otherwise conflict with the theme minimum.
  final double? height;

  const SolaceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SolaceButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  bool get _isDisabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final spinnerSize = height != null ? height! * 0.6 : 22.0;
    final textStyle = height != null
        ? AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)
        : null;

    final child = isLoading
        ? SizedBox(
            height: spinnerSize,
            width: spinnerSize,
            child: const CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8)
              ],
              Text(label, style: textStyle),
            ],
          );

    final compactPadding = height != null
        ? EdgeInsets.symmetric(horizontal: 14, vertical: height! * 0.2)
        : null;

    final Widget button = switch (variant) {
      SolaceButtonVariant.primary => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0, height ?? 52),
            padding: compactPadding,
            shape: height == null
                ? null
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height! / 2),
                  ),
          ),
          child: child,
        ),
      SolaceButtonVariant.secondary => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            minimumSize: Size(0, height ?? 52),
            padding: compactPadding,
            textStyle: AppTextStyles.button,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(height != null ? height! / 2 : 14)),
          ),
          child: child,
        ),
      SolaceButtonVariant.outline => OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, height ?? 52),
            padding: compactPadding,
            shape: height == null
                ? null
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height! / 2),
                  ),
          ),
          child: isLoading
              ? SizedBox(
                  height: spinnerSize,
                  width: spinnerSize,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2.4, color: AppColors.primary),
                )
              : child,
        ),
    };

    return SizedBox(width: width, child: button);
  }
}
