import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/coming_soon_tab.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import 'home_screen.dart';

/// The scaffold AuthGate hands off to once someone is authenticated +
/// verified. Owns bottom-nav tab state itself (an int index) rather than
/// using named Navigator routes per tab, matching CustomBottomNavBar's
/// existing "Home, Therapists, Circles, Chat, Profile" design.
///
/// HomeBloc is provided here, not in app.dart's MultiBlocProvider — it
/// only needs to exist while someone is logged in and looking at these
/// tabs, and it needs the signed-in user's preferences at construction
/// time, which aren't available until AuthBloc reaches AuthAuthenticated
/// anyway.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userConcerns = switch (authState) {
      AuthAuthenticated(user: final user) => user.preferences,
      _ => const <String>[],
    };

    return BlocProvider(
      create: (_) => HomeBloc(userConcerns: userConcerns),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(onNavigateToTab: _goToTab),
            const ComingSoonTab(
              title: 'Therapists',
              icon: Icons.psychology_alt_rounded,
              partLabel: 'Part F (Therapist Directory & Search)',
            ),
            const ComingSoonTab(
              title: 'Circles',
              icon: Icons.groups_rounded,
              partLabel: 'Part I (Community Circles)',
            ),
            const ComingSoonTab(
              title: 'Chat',
              icon: Icons.chat_bubble_rounded,
              partLabel: 'Part J (Real-Time Chat)',
            ),
            const ComingSoonTab(
              title: 'Profile',
              icon: Icons.person_rounded,
              partLabel: 'Part M (Profile & Settings)',
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
        ),
      ),
    );
  }
}
