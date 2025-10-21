import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin StateNotifierStateMixin<T> on StateNotifier<T> {
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void safeUpdate(T Function(T state) updater) {
    if (!mounted) return;
    state = updater(state);
  }
}

abstract class AsyncStateNotifier<T> extends StateNotifier<AsyncValue<T>> {
  AsyncStateNotifier() : super(const AsyncValue.loading());

  Future<void> handleAsync(Future<T> Function() operation) async {
    try {
      state = const AsyncValue.loading();
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}