import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

/// Cancels any in-progress handler as soon as a newer event arrives,
/// so a stale in-flight request can never overwrite a fresher one.
EventTransformer<E> restartable<E>() {
  return (events, mapper) => events.switchMap(mapper);
}

/// Waits for the given [duration] of silence before letting an event
/// through, then applies [restartable] semantics — used for search-as-
/// you-type so typing doesn't fire an API call per keystroke and a
/// superseded search can't land after a newer one.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
