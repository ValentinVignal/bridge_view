import 'package:riverpod/riverpod.dart';

typedef StateProviderCreateFunction<T> = T Function(Ref ref);

abstract class StateProvider<T> {
  static NotifierProvider<StateNotifier<T>, T> autoDispose<T>(
    StateProviderCreateFunction<T> createFunction,
  ) {
    return NotifierProvider.autoDispose<StateNotifier<T>, T>(
      () => StateNotifier<T>(createFunction),
    );
  }
}

class StateNotifier<T> extends Notifier<T> {
  StateNotifier(this._createFunction);

  final StateProviderCreateFunction<T> _createFunction;

  @override
  T build() => _createFunction(ref);

  @override
  T get state => super.state;

  @override
  set state(T newState) {
    super.state = newState;
  }

  void update(T Function(T) updateFn) {
    state = updateFn(state);
  }
}
