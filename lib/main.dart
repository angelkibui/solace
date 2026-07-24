import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  // Wrapped in try/catch so the app still runs (design system + onboarding
  // preview) before Part A2's Firebase Console project / `flutterfire
  // configure` step has been completed. Once that's done, this call
  // connects the app to Firebase for real.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Firebase did not initialize: $e\n'
        'Run `flutterfire configure` and finish Part A2 (Firebase Console '
        'setup) to enable backend features.',
      );
    }
  }

  runApp(const SolaceApp());
}