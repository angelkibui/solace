import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/concern_chip.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Profile & Settings tab (Part M).
/// Reads the current [UserModel] from [AuthBloc] and lets the user:
///   • Edit their alias.
///   • Toggle concern preferences (same chips used during onboarding).
///   • Switch between light and dark mode.
///   • Sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _aliasController;
  late Set<String> _selectedConcerns;
  bool _isEditing = false;

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
    _selectedConcerns = {};
    _syncFromBloc();
  }

  void _syncFromBloc() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _user = state.user;
      _aliasController.text = state.user.alias;
      _selectedConcerns = Set<String>.from(state.user.preferences);
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  void _startEditing() => setState(() => _isEditing = true);

  void _cancelEditing() {
    _syncFromBloc();
    setState(() => _isEditing = false);
  }

  void _saveProfile() {
    final user = _user;
    if (user == null) return;
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alias cannot be empty.')),
      );
      return;
    }
    context.read<AuthBloc>().add(ProfileUpdateRequested(
          uid: user.uid,
          alias: alias,
          preferences: _selectedConcerns.toList(),
        ));
    setState(() => _isEditing = false);
  }

  void _toggleConcern(String concern) {
    setState(() {
      if (_selectedConcerns.contains(concern)) {
        _selectedConcerns.remove(concern);
      } else {
        _selectedConcerns.add(concern);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _user = state.user;
          if (!_isEditing) {
            _aliasController.text = state.user.alias;
            _selectedConcerns = Set<String>.from(state.user.preferences);
          }
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final user = _user;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Profile & Settings',
            showBackButton: false,
            actions: [
              if (!_isEditing)
                IconButton(
                  tooltip: 'Edit profile',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _startEditing,
                ),
              if (_isEditing) ...[
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isLoading ? null : _saveProfile,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── Avatar & identity header ──────────────────────────────
                _AvatarHeader(
                  alias: user?.alias ?? '…',
                  email: user?.email ?? '',
                  createdAt: user?.createdAt,
                  isEditing: _isEditing,
                  aliasController: _aliasController,
                ),
                const SizedBox(height: 28),

                // ── Concerns ──────────────────────────────────────────────
                const _SectionLabel(label: 'Your concerns'),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Tap to add or remove concerns. These personalise your recommendations.'
                      : 'These personalise your therapist recommendations.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.concerns.map((option) {
                    final selected = _selectedConcerns.contains(option.title);
                    return ConcernChip(
                      label: option.title,
                      isSelected: selected,
                      onSelected: _isEditing ? (_) => _toggleConcern(option.title) : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // ── Appearance ────────────────────────────────────────────
                const _SectionLabel(label: 'Appearance'),
                const SizedBox(height: 8),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return _SettingsTile(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'Dark mode',
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleTheme(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Push notifications',
                  subtitle: 'Managed through your device settings.',
                  trailing: SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // ── Account ───────────────────────────────────────────────
                const _SectionLabel(label: 'Account'),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Data',
                  subtitle: 'Your data is stored securely and never sold.',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy details coming soon.'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Sign out ──────────────────────────────────────────────
                SolaceButton(
                  label: 'Sign out',
                  variant: SolaceButtonVariant.outline,
                  icon: Icons.logout_rounded,
                  onPressed: isLoading
                      ? null
                      : () => _confirmLogout(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will be returned to the login screen. Your anonymous alias and data are kept safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }
}

// ─── Local widgets ───────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final String alias;
  final String email;
  final DateTime? createdAt;
  final bool isEditing;
  final TextEditingController aliasController;

  const _AvatarHeader({
    required this.alias,
    required this.email,
    required this.createdAt,
    required this.isEditing,
    required this.aliasController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = alias.isNotEmpty ? alias[0].toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            initial,
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.primary,
              fontSize: 38,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              controller: aliasController,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium,
              maxLength: 30,
              decoration: const InputDecoration(
                hintText: 'Your alias',
                counterText: '',
              ),
            ),
          )
        else
          Text(alias, style: AppTextStyles.headingMedium),
        const SizedBox(height: 4),
        Text(
          email,
          style: AppTextStyles.bodySmall,
        ),
        if (createdAt != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since ${DateFormat('MMMM yyyy').format(createdAt!)}',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCardBackground : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
