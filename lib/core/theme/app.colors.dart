import 'package:flutter/material.dart';

/// Design tokens pulled from the Figma prototype. Two accent colors do
/// different jobs in the design, not one — don't collapse them:
///   - [navy]  → the onboarding hero CTA, sent chat bubbles, dark icon buttons
///   - [primary] (green) → the "do the thing" action color used almost
///     everywhere else: Book Consultation, Pay with MoMo, Enter Circle,
///     the active bottom-nav pill
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF1E2A45);
  static const Color navyLight = Color(0xFF32456B);
  static const Color primary = Color(0xFF2FAE58); // main action green
  static const Color primaryLight = Color(0xFF5FCB7E);
  static const Color primaryDark = Color(0xFF1F8A42);
  static const Color coral = Color(0xFFE2585F); // badges, end-call, alerts

  // Light theme surfaces — soft mint/blue gradient background from the
  // Figma screens; cards sit on top in solid white.
  static const Color backgroundTop = Color(0xFFEAF2EE);
  static const Color backgroundBottom = Color(0xFFDFEEE6);
  static const Color background = Color(0xFFEAF2EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE3E9E5);

  // Light theme text
  static const Color textPrimary = Color(0xFF1B2A3D);
  static const Color textSecondary = Color(0xFF6B7785);
  static const Color textDisabled = Color(0xFFAEB6C0);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF10151F);
  static const Color darkSurface = Color(0xFF1A2130);
  static const Color darkCardBackground = Color(0xFF212A3B);
  static const Color darkDivider = Color(0xFF2E3A4E);

  // Dark theme text
  static const Color darkTextPrimary = Color(0xFFEDEFF3);
  static const Color darkTextSecondary = Color(0xFFA3ACC0);

  // Status
  static const Color error = Color(0xFFE2585F);
  static const Color success = Color(0xFF2FAE58);
  static const Color warning = Color(0xFFE8A75D);
  static const Color info = Color(0xFF3B7DD8);

  // Chat bubbles
  static const Color bubbleSent = navy;
  static const Color bubbleReceived = Color(0xFFF1F4F2);
  static const Color darkBubbleReceived = Color(0xFF2A3244);

  /// Pastel icon-tint pairs (background, foreground) cycled across the
  /// concern list tiles and other icon chips so each item reads distinctly
  /// without needing a bespoke color per item.
  static const List<List<Color>> iconTints = [
    [Color(0xFFDCF1E3), Color(0xFF2F9E5C)], // green
    [Color(0xFFDCE8F7), Color(0xFF3B7DD8)], // blue
    [Color(0xFFF7E1E9), Color(0xFFD6538A)], // pink
    [Color(0xFFEDE1F7), Color(0xFF8A4FCF)], // purple
    [Color(0xFFFBEBD6), Color(0xFFD68A2F)], // amber
    [Color(0xFFFCE1E1), Color(0xFFD65B5B)], // coral
    [Color(0xFFDAF1EE), Color(0xFF1F9E8E)], // teal
  ];
}
