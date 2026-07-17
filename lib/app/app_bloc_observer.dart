// ──────────────────────────────────────────────────────────────
// APP BLOC OBSERVER
// ──────────────────────────────────────────────────────────────
// A global observer attached to ALL Blocs in the application.
//
// Every time any Bloc in the app:
//   - receives an Event
//   - transitions from one State to another
//   - throws an Error
//   - is created or closed
// ...this observer logs it.
//
// This is the debugging superpower of flutter_bloc. Without it,
// Bloc state changes happen invisibly. With it, you can trace
// exactly what events triggered what state changes.
//
// Production tip: Set a breakpoint in onError to catch unexpected
// failures before they reach the user.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/services/logger_service.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._logger);

  final LoggerService _logger;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.debug('Bloc created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.debug('Bloc Event: ${bloc.runtimeType} -> $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.debug('Bloc Transition: ${bloc.runtimeType} -> $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error('Bloc Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.debug('Bloc Change: ${bloc.runtimeType} -> $change');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.debug('Bloc closed: ${bloc.runtimeType}');
  }
}
