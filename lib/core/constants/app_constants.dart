import 'package:flutter/material.dart';

class ConcernOption {
  final String title;
  final String description;
  final IconData icon;

  const ConcernOption(
      {required this.title, required this.description, required this.icon});
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Solace';
  static const String appTagline =
      'Healing begins with a safe space. No names, no labels, just you.';

  static const List<ConcernOption> concerns = <ConcernOption>[
    ConcernOption(
      title: 'Work Stress',
      description:
          'Pressure, deadlines, or burnout in your professional environment.',
      icon: Icons.work_outline_rounded,
    ),
    ConcernOption(
      title: 'Anxiety',
      description: 'Racing thoughts, restlessness, or persistent worry.',
      icon: Icons.psychology_alt_outlined,
    ),
    ConcernOption(
      title: 'Depression',
      description: 'Low mood, loss of interest, or emotional heaviness.',
      icon: Icons.cloud_outlined,
    ),
    ConcernOption(
      title: 'Recovery Challenges',
      description: 'Staying steady through setbacks on your recovery journey.',
      icon: Icons.spa_outlined,
    ),
    ConcernOption(
      title: 'Relationship Issues',
      description:
          'Conflict, distance, or communication struggles with people close to you.',
      icon: Icons.favorite_border_rounded,
    ),
    ConcernOption(
      title: 'Grief & Loss',
      description: 'Coping with the loss of someone or something important.',
      icon: Icons.local_florist_outlined,
    ),
    ConcernOption(
      title: 'Sleep Issues',
      description: 'Trouble falling asleep, staying asleep, or feeling rested.',
      icon: Icons.bedtime_outlined,
    ),
    ConcernOption(
      title: 'Self-Esteem',
      description: 'Doubt, comparison, or difficulty valuing yourself.',
      icon: Icons.emoji_emotions_outlined,
    ),
    ConcernOption(
      title: 'Family Conflict',
      description: 'Tension or misunderstandings within your family.',
      icon: Icons.groups_outlined,
    ),
  ];

  static const List<Color> presenceColors = <Color>[
    Color(0xFF3B7DD8),
    Color(0xFF8B95A1),
    Color(0xFF2B2F38),
    Color(0xFFE8B99A),
    Color(0xFF2FAE58),
  ];
}
