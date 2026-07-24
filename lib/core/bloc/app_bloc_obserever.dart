import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs every Bloc/Cubit transition to the console in debug mode.
///
/// Wired up once in `main.dart` via `Bloc.observer = AppBlocObserver();`.
/// Makes it easy to see exactly which state a screen is in during the demo
/// recording, and helps debug "why didn't the UI update" issues.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) debugPrint('🟢 onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('🔄 onChange -- ${bloc.runtimeType}\n$change');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) debugPrint('📩 onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) debugPrint('🔴 onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (kDebugMode) debugPrint('⚪ onClose -- ${bloc.runtimeType}');
  }
}
