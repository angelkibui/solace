import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/circle_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../data/models/circle_model.dart';
import '../bloc/circle_bloc.dart';
import '../bloc/circle_event.dart';
import '../bloc/circle_state.dart';
import 'circle_detail_screen.dart';

class CirclesListScreen extends StatelessWidget {
  const CirclesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _CirclesHeader(),
            const _TabSelector(),
            const SizedBox(height: 8),
            const _CategoryChips(),
            const SizedBox(height: 12),
            Expanded(
              child: BlocConsumer<CircleBloc, CircleState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage &&
                    current.errorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                },
                builder: (context, state) {
                  if (state.status == CircleStatus.loading &&
                      state.circles.isEmpty) {
                    return const LoadingShimmer(itemCount: 3, itemHeight: 190);
                  }

                  if (state.status == CircleStatus.failure &&
                      state.circles.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.cloud_off_rounded,
                      title: 'We could not load circles',
                      subtitle: state.errorMessage,
                      actionLabel: 'Try again',
                      onAction: () => context
                          .read<CircleBloc>()
                          .add(const CirclesRequested()),
                    );
                  }

                  final circles = state.visibleCircles;
                  if (circles.isEmpty) {
                    return EmptyStateWidget(
                      icon: state.myCirclesOnly
                          ? Icons.groups_outlined
                          : Icons.manage_search_rounded,
                      title: state.myCirclesOnly
                          ? "You haven't joined any circles yet"
                          : 'No circles in this category',
                      subtitle: state.myCirclesOnly
                          ? 'Browse All Circles and join one that resonates with you.'
                          : 'Try a different category.',
                      actionLabel:
                          state.myCirclesOnly ? 'Browse All Circles' : null,
                      onAction: state.myCirclesOnly
                          ? () => context
                              .read<CircleBloc>()
                              .add(const CircleTabChanged(false))
                          : null,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CircleBloc>().add(
                            const CirclesRequested(refresh: true),
                          );
                      await context.read<CircleBloc>().stream.firstWhere(
                            (next) => next.status != CircleStatus.refreshing,
                          );
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: circles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _CircleResultCard(circle: circles[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclesHeader extends StatelessWidget {
  const _CirclesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Circles',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Anonymous, moderated peer support — you\'re never alone in this.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// I2 — "All Circles" / "My Circles" tabs. A plain Row of two ChoiceChip-
/// styled buttons rather than a Material TabBar, since there's no
/// TabController/TabBarView pagination need here — CircleBloc's
/// myCirclesOnly flag already drives which circles show through
/// visibleCircles, so switching tabs is just one field changing.
class _TabSelector extends StatelessWidget {
  const _TabSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(
      buildWhen: (previous, current) =>
          previous.myCirclesOnly != current.myCirclesOnly,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'All Circles',
                  selected: !state.myCirclesOnly,
                  onTap: () => context
                      .read<CircleBloc>()
                      .add(const CircleTabChanged(false)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TabButton(
                  label: 'My Circles',
                  selected: state.myCirclesOnly,
                  onTap: () => context
                      .read<CircleBloc>()
                      .add(const CircleTabChanged(true)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.transparent : colors.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// I3 — category chips, populated from whatever categories are actually
/// present in the loaded circles rather than a hardcoded list, so this
/// never drifts out of sync with real data the way a fixed list could.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(
      buildWhen: (previous, current) =>
          previous.category != current.category ||
          previous.circles.length != current.circles.length,
      builder: (context, state) {
        final categories = state.availableCategories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final value = isAll ? null : categories[index - 1];
              final selected =
                  isAll ? state.category == null : state.category == value;
              return ChoiceChip(
                selected: selected,
                label: Text(isAll ? 'All Categories' : value!),
                onSelected: (_) => context
                    .read<CircleBloc>()
                    .add(CircleCategoryChanged(value)),
              );
            },
          ),
        );
      },
    );
  }
}

class _CircleResultCard extends StatelessWidget {
  final CircleModel circle;

  const _CircleResultCard({required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(
      buildWhen: (previous, current) =>
          previous.pendingCircleIds.contains(circle.id) !=
              current.pendingCircleIds.contains(circle.id) ||
          previous.userId != current.userId,
      builder: (context, state) {
        final isJoined = circle.isJoinedBy(state.userId);
        final isPending = state.pendingCircleIds.contains(circle.id);
        return CircleCard(
          title: circle.name,
          description: circle.description,
          memberCount: circle.memberCount,
          imageUrl: circle.imageUrl.isEmpty ? null : circle.imageUrl,
          isJoined: isJoined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CircleBloc>(),
                child: CircleDetailScreen(circleId: circle.id),
              ),
            ),
          ),
          onJoinToggle: isPending
              ? null
              : () =>
                  context.read<CircleBloc>().add(CircleJoinToggled(circle.id)),
        );
      },
    );
  }
}
