import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/coming_soon_tab.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_event.dart';
import '../../../appointments/presentation/pages/booking_flow_screen.dart';
import '../../../appointments/presentation/pages/my_appointments_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/pages/payment_checkout_screen.dart';
import '../../../payments/presentation/pages/transaction_history_screen.dart';
import '../../../therapists/data/models/therapist_model.dart';
import '../../../therapists/data/repositories/therapist_repository.dart';
import '../../../therapists/presentation/bloc/therapist_bloc.dart';
import '../../../therapists/presentation/bloc/therapist_event.dart';
import '../../../therapists/presentation/pages/therapist_list_screen.dart';
import '../bloc/home_bloc.dart';
import 'home_screen.dart';

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
    final user = switch (authState) {
      AuthAuthenticated(user: final u) => u,
      _ => null,
    };
    // MainShell only ever renders while AuthGate is in the AuthAuthenticated
   
    final userId = user?.uid ?? '';
    final userConcerns = user?.preferences ?? const <String>[];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc(userConcerns: userConcerns)),
        BlocProvider(
          create: (_) => TherapistBloc(TherapistRepository())..add(const TherapistsRequested()),
        ),
        BlocProvider(
          create: (_) => AppointmentBloc(AppointmentRepository())..add(AppointmentsRequested(userId)),
        ),
        BlocProvider(
          create: (_) => PaymentBloc(PaymentRepository())..add(TransactionsRequested(userId)),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateToTab: _goToTab),
              TherapistListScreen(
                onBookTherapist: (therapist) => _openBooking(context, therapist, userId),
                onOpenAppointments: () => _openAppointments(context),
                onOpenTransactions: () => _openTransactions(context),
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
      ),
    );
  }

  void _openAppointments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AppointmentBloc>(),
          child: const MyAppointmentsScreen(),
        ),
      ),
    );
  }

  void _openTransactions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PaymentBloc>(),
          child: const TransactionHistoryScreen(),
        ),
      ),
    );
  }

  void _openBooking(BuildContext context, TherapistModel therapist, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AppointmentBloc>(),
          child: BookingFlowScreen(
            userId: userId,
            therapist: therapist,
            onAppointmentCreated: (appointment) => _openCheckout(context, appointment, therapist),
          ),
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context, AppointmentModel appointment, TherapistModel therapist) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AppointmentBloc>()),
            BlocProvider.value(value: context.read<PaymentBloc>()),
          ],
          child: PaymentCheckoutScreen(appointment: appointment, therapist: therapist),
        ),
      ),
    );
  }
}
