import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';

class SolaceApp extends StatelessWidget {
  /// Set in main.dart based on whether Firebase.initializeApp() actually
  /// succeeded. AuthRepository's constructor touches FirebaseAuth.instance
  /// unconditionally, which throws immediately if Firebase never
  /// initialized (wrong platform not covered by flutterfire configure, no
  /// internet, bad project config, etc.) — so when this is false, we skip
  /// building AuthBloc/AuthRepository entirely and show a plain error
  /// screen instead of letting that exception crash the whole widget tree.
  final bool firebaseReady;

  const SolaceApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return const _FirebaseUnavailableApp();
    }

    final prefsService = SharedPrefsService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefsService)),
        BlocProvider(create: (_) => OnboardingCubit(prefsService)),
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
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
<<<<<<< HEAD
=======

/// Shown instead of the real app when Firebase couldn't initialize.
/// Deliberately has no MultiBlocProvider/AuthBloc underneath it — nothing
/// in this subtree is allowed to touch Firebase.
class _FirebaseUnavailableApp extends StatelessWidget {
  const _FirebaseUnavailableApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 20),
                  Text("Can't connect right now", style: AppTextStyles.headingSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Solace needs a working connection to start. Check your internet '
                    'connection and restart the app.\n\n'
                    '(Developer note: this platform target may not be covered by '
                    'firebase_options.dart yet — run `flutterfire configure` and '
                    'include it.)',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
