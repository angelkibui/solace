import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/therapist_card.dart';
import '../../../../core/widgets/circle_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/quick_action_card.dart';

// HomeScreen is the main landing page for the app
class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final alias = switch (context.watch<AuthBloc>().state) {
      AuthAuthenticated(user: final user) => user.alias,
      _ => 'there',
    };

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshRequested());
           
            await Future.delayed(const Duration(milliseconds: 700));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('$_greeting, $alias', style: AppTextStyles.headingMedium),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'How are you feeling today?',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    QuickActionCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'Book a Session',
                      tint: AppColors.iconTints[0],
                      onTap: () => widget.onNavigateToTab(1),
                    ),
                    const SizedBox(width: 10),
                    QuickActionCard(
                      icon: Icons.groups_rounded,
                      label: 'Join a Circle',
                      tint: AppColors.iconTints[1],
                      onTap: () => widget.onNavigateToTab(2), 
                    ),
                    const SizedBox(width: 10),
                    QuickActionCard(
                      icon: Icons.quiz_outlined,
                      label: 'Take Assessment',
                      tint: AppColors.iconTints[4],
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assessment feature is planned but not yet built.')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return switch (state) {
                    HomeInitial() || HomeLoading() => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(title: 'Recommended for you', onSeeAll: null),
                          SizedBox(height: 12),
                          SizedBox(height: 160, child: LoadingShimmer(itemCount: 2, itemHeight: 160)),
                        ],
                      ),
                    HomeError(:final message) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyStateWidget(
                          icon: Icons.error_outline_rounded,
                          title: 'Something went wrong',
                          subtitle: message,
                        ),
                      ),
                    HomeLoaded(:final recommendedTherapists, :final trendingCircles, :final isPersonalized) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Recommended for you',
                            onSeeAll: () => widget.onNavigateToTab(1),
                          ),
                          if (!isPersonalized)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Text(
                                'Select a few concerns in your profile to personalize this list.',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final (i, t) in recommendedTherapists.indexed) ...[
                                  SizedBox(
                                    width: 280,
                                    child: TherapistCard(
                                      name: t.name,
                                      roleLabel: t.roleLabel,
                                      traits: t.concernTags,
                                      bio: t.bio,
                                      languages: t.languages,
                                      rate: t.rate,
                                      rating: t.rating,
                                      reviewCount: t.reviewCount,
                                      onTap: () => widget.onNavigateToTab(1),
                                      onBook: () => widget.onNavigateToTab(1),
                                    ),
                                  ),
                                  if (i != recommendedTherapists.length - 1) const SizedBox(width: 12),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            title: 'Trending Circles',
                            onSeeAll: () => widget.onNavigateToTab(2),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final (i, c) in trendingCircles.indexed) ...[
                                  SizedBox(
                                    width: 220,
                                    child: CircleCard(
                                      title: c.title,
                                      description: c.description,
                                      memberCount: c.memberCount,
                                      onTap: () => widget.onNavigateToTab(2),
                                      onJoinToggle: () => widget.onNavigateToTab(2),
                                    ),
                                  ),
                                  if (i != trendingCircles.length - 1) const SizedBox(width: 12),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                  };
                },
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Upcoming Sessions', style: AppTextStyles.headingSmall),
              ),
              const SizedBox(height: 12),
              EmptyStateWidget(
                icon: Icons.event_available_outlined,
                title: 'No upcoming sessions',
                subtitle: 'Book a consultation with a therapist to see it here.',
                actionLabel: 'Book a Session',
                onAction: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }
}
