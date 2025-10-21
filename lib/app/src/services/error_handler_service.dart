import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';

class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  AppError(this.message, {this.code, this.originalError, this.stackTrace});
  
  @override
  String toString() => 'AppError: $message${code != null ? ' (code: $code)' : ''}';
}

class ErrorEvent extends AppEvent {
  final AppError error;
  ErrorEvent(this.error);
}

final errorHandlerProvider = Provider<ErrorHandlerService>((ref) {
  final eventBus = ref.watch(eventBusProvider);
  return ErrorHandlerService(eventBus);
});

class ErrorHandlerService {
  final EventBus _eventBus;
  
  ErrorHandlerService(this._eventBus);
  
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    final appError = error is AppError 
      ? error 
      : AppError(
          error.toString(),
          originalError: error,
          stackTrace: stackTrace,
        );
    
    _eventBus.emit(ErrorEvent(appError));
  }
  
  Never throwAppError(String message, {String? code}) {
    throw AppError(message, code: code);
  }
}