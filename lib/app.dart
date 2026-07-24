import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';

/// App root: wires up every app-wide Cubit/Bloc via MultiBlocProvider and
/// rebuilds MaterialApp's theme when ThemeCubit changes. Feature-scoped
/// Blocs (AppointmentBloc, ChatCubit, etc.) will be provided closer to
/// where they're used once those parts are built, not here.
class SolaceApp extends StatelessWidget {
  const SolaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsService = SharedPrefsService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefsService)),
        BlocProvider(create: (_) => OnboardingCubit(prefsService)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Solace',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}