import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Displays a call/session duration as MM:SS. Purely presentational —
/// Part K's CallCubit owns the actual ticking Timer/Stream and just
/// rebuilds this widget with the latest Duration.
class SessionTimer extends StatelessWidget {
  final Duration duration;
  final TextStyle? style;

  const SessionTimer({super.key, required this.duration, this.style});

  static String format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      format(duration),
      style: style ?? AppTextStyles.titleMedium.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}