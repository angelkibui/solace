import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../bloc/circle_bloc.dart';
import '../bloc/circle_event.dart';
import '../bloc/circle_state.dart';

class CircleDetailScreen extends StatelessWidget {
  final String circleId;

  const CircleDetailScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Circle'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<CircleBloc, CircleState>(
          builder: (context, state) {
            final matches = state.circles.where((c) => c.id == circleId);
            final circle = matches.isEmpty ? null : matches.first;
            if (circle == null) {
              return const Center(child: Text('This circle is no longer available.'));
            }

            final isJoined = circle.isJoinedBy(state.userId);
            final isPending = state.pendingCircleIds.contains(circleId);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: circle.imageUrl.isEmpty
                              ? Container(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: AppColors.primary,
                                    size: 48,
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: circle.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(circle.name, style: AppTextStyles.headingLarge),
                          ),
                          if (circle.isModerated)
                            const Tooltip(
                              message: 'Moderated space',
                              child: Icon(Icons.verified_user_rounded, color: AppColors.primary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(circle.category, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 18),
                      _InfoRow(
                        icon: Icons.people_alt_outlined,
                        label: '${circle.memberCount} members',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: circle.isModerated
                            ? 'Moderated by ${circle.moderatorName}'
                            : 'Unmoderated peer space',
                      ),
                      const SizedBox(height: 24),
                      Text('About this circle', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 8),
                      Text(circle.description, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 32),
                      SolaceButton(
                        label: isJoined ? 'Enter Circle' : 'Join to Enter',
                        isLoading: isPending,
                        onPressed: () {
                          if (isJoined) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Circle chat arrives with Part J (Real-Time Chat).'),
                              ),
                            );
                          } else {
                            context.read<CircleBloc>().add(CircleJoinToggled(circleId));
                          }
                        },
                      ),
                      if (isJoined) ...[
                        const SizedBox(height: 10),
                        SolaceButton(
                          label: 'Leave Circle',
                          variant: SolaceButtonVariant.outline,
                          isLoading: isPending,
                          onPressed: () =>
                              context.read<CircleBloc>().add(CircleJoinToggled(circleId)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
