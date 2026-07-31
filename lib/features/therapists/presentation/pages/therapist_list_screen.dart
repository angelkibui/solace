import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/therapist_card.dart';
import '../../data/models/therapist_model.dart';
import '../bloc/therapist_bloc.dart';
import '../bloc/therapist_event.dart';
import '../bloc/therapist_state.dart';
import 'therapist_detail_screen.dart';

class TherapistListScreen extends StatelessWidget {
  final ValueChanged<TherapistModel>? onBookTherapist;

  const TherapistListScreen({super.key, this.onBookTherapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _DirectoryHeader(onFilterPressed: () => _showFilters(context)),
            const _QuickFilters(),
            const SizedBox(height: 12),
            Expanded(
              child: BlocConsumer<TherapistBloc, TherapistState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage &&
                    current.errorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                },
                builder: (context, state) {
                  if (state.status == TherapistStatus.loading &&
                      state.therapists.isEmpty) {
                    return const LoadingShimmer(itemCount: 3, itemHeight: 250);
                  }

                  if (state.status == TherapistStatus.failure &&
                      state.therapists.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.cloud_off_rounded,
                      title: 'We could not load professionals',
                      subtitle: state.errorMessage,
                      actionLabel: 'Try again',
                      onAction: () => context.read<TherapistBloc>().add(
                            const TherapistsRequested(),
                          ),
                    );
                  }

                  final therapists = state.visibleTherapists;
                  if (therapists.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.manage_search_rounded,
                      title: 'No matching professionals',
                      subtitle:
                          'Try another name, specialty, language, or price range.',
                      actionLabel: 'Clear filters',
                      onAction: () => context.read<TherapistBloc>().add(
                            const TherapistFiltersCleared(),
                          ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TherapistBloc>().add(
                            const TherapistsRequested(refresh: true),
                          );
                      await context.read<TherapistBloc>().stream.firstWhere(
                            (next) => next.status != TherapistStatus.refreshing,
                          );
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 760 ? 2 : 1;
                        if (columns == 1) {
                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: therapists.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) =>
                                _TherapistResultCard(
                              therapist: therapists[index],
                              onBook: () =>
                                  _openBooking(context, therapists[index]),
                            ),
                          );
                        }

                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 380,
                          ),
                          itemCount: therapists.length,
                          itemBuilder: (context, index) => _TherapistResultCard(
                            therapist: therapists[index],
                            onBook: () =>
                                _openBooking(context, therapists[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This section is being prepared by another team member.',
              ),
            ),
          );
        },
      ),
    );
  }

  void _openBooking(BuildContext context, TherapistModel therapist) {
    if (onBookTherapist != null) {
      onBookTherapist!(therapist);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TherapistDetailScreen(
          therapist: therapist,
          onBook: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Choose a date to continue with this professional.',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) async {
    final bloc = context.read<TherapistBloc>();
    final result = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TherapistFilterSheet(initialState: bloc.state),
    );
    if (result == null || !context.mounted) return;
    bloc.add(
      TherapistFiltersChanged(
        specialty: result.specialty,
        language: result.language,
        gender: result.gender,
        maximumRate: result.maximumRate,
      ),
    );
  }
}

class _DirectoryHeader extends StatelessWidget {
  final VoidCallback onFilterPressed;

  const _DirectoryHeader({required this.onFilterPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Licensed Professionals',
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verified Rwandan support, matched to your needs.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Filter professionals',
                onPressed: onFilterPressed,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => context.read<TherapistBloc>().add(
                  TherapistSearchChanged(value),
                ),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search by name, role, or specialty',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  const _QuickFilters();

  static const values = [
    'All Specialties',
    'Anxiety',
    'Trauma',
    'Grief Support',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TherapistBloc, TherapistState>(
      buildWhen: (previous, current) => previous.specialty != current.specialty,
      builder: (context, state) {
        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = values[index];
              final selected = index == 0
                  ? state.specialty == null
                  : state.specialty == value;
              return ChoiceChip(
                selected: selected,
                label: Text(value),
                onSelected: (_) => context.read<TherapistBloc>().add(
                      TherapistFiltersChanged(
                        specialty: index == 0 ? null : value,
                        language: state.language,
                        gender: state.gender,
                        maximumRate: state.maximumRate,
                      ),
                    ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TherapistResultCard extends StatelessWidget {
  final TherapistModel therapist;
  final VoidCallback onBook;

  const _TherapistResultCard({required this.therapist, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern();
    return TherapistCard(
      name: therapist.name,
      roleLabel: therapist.title,
      traits: therapist.specialties.take(3).toList(),
      bio: therapist.bio,
      languages: therapist.languages,
      rate: '${currency.format(therapist.rate)} RWF / hr',
      imageUrl: therapist.photoUrl.isEmpty ? null : therapist.photoUrl,
      rating: therapist.rating,
      reviewCount: therapist.reviewCount,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              TherapistDetailScreen(therapist: therapist, onBook: onBook),
        ),
      ),
      onBook: onBook,
      secondaryActionIcon: Icons.call_outlined,
      onSecondaryAction: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book a session before starting a private call.'),
        ),
      ),
    );
  }
}

class _FilterSelection {
  final String? specialty;
  final String? language;
  final String? gender;
  final int? maximumRate;

  const _FilterSelection({
    this.specialty,
    this.language,
    this.gender,
    this.maximumRate,
  });
}

class _TherapistFilterSheet extends StatefulWidget {
  final TherapistState initialState;

  const _TherapistFilterSheet({required this.initialState});

  @override
  State<_TherapistFilterSheet> createState() => _TherapistFilterSheetState();
}

class _TherapistFilterSheetState extends State<_TherapistFilterSheet> {
  static const specialties = [
    'Anxiety',
    'Trauma',
    'Grief Support',
    'Work Stress',
  ];
  static const languages = ['Kinyarwanda', 'English', 'French'];
  static const genders = ['Female', 'Male'];
  static const rates = [20000, 35000, 50000, 75000];

  String? specialty;
  String? language;
  String? gender;
  int? maximumRate;

  @override
  void initState() {
    super.initState();
    specialty = widget.initialState.specialty;
    language = widget.initialState.language;
    gender = widget.initialState.gender;
    maximumRate = widget.initialState.maximumRate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Refine your match', style: AppTextStyles.headingMedium),
            const SizedBox(height: 20),
            _FilterGroup(
              label: 'Specialty',
              values: specialties,
              selected: specialty,
              onSelected: (value) => setState(() => specialty = value),
            ),
            _FilterGroup(
              label: 'Language',
              values: languages,
              selected: language,
              onSelected: (value) => setState(() => language = value),
            ),
            _FilterGroup(
              label: 'Gender',
              values: genders,
              selected: gender,
              onSelected: (value) => setState(() => gender = value),
            ),
            Text('Maximum hourly rate', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rates.map((rate) {
                return ChoiceChip(
                  selected: maximumRate == rate,
                  label: Text('${NumberFormat.compact().format(rate)} RWF'),
                  onSelected: (selected) =>
                      setState(() => maximumRate = selected ? rate : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      specialty = null;
                      language = null;
                      gender = null;
                      maximumRate = null;
                    }),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(
                      _FilterSelection(
                        specialty: specialty,
                        language: language,
                        gender: gender,
                        maximumRate: maximumRate,
                      ),
                    ),
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final List<String> values;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _FilterGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              return ChoiceChip(
                selected: selected == value,
                label: Text(value),
                onSelected: (isSelected) =>
                    onSelected(isSelected ? value : null),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
