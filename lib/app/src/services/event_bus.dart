import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  void emit(AppEvent event) {
    _controller.add(event);
  }

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void dispose() {
    _controller.close();
  }
}

abstract class AppEvent {}

class NotificationClickEvent extends AppEvent {
  final String payload;

  NotificationClickEvent(this.payload);
}

final eventBusProvider = Provider<EventBus>((ref) {
  final eventBus = EventBus();
  ref.onDispose(() => eventBus.dispose());
  return eventBus;
});
