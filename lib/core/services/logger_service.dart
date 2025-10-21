import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:widmate/core/errors/app_errors.dart';

/// Log levels for different types of messages
enum LogLevel { debug, info, warning, error, fatal }

/// Centralized logging service
class Logger {
  static const String _tag = 'WidMate';

  /// Log a debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Log an error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Log a fatal error message
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error, stackTrace);
  }

  /// Log an AppError
  static void logError(AppError appError) {
    _log(
      LogLevel.error,
      appError.message,
      appError.originalError,
      appError.stackTrace,
    );
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final levelString = level.name.toUpperCase();
      final logMessage = '[$timestamp] [$levelString] $_tag: $message';

      switch (level) {
        case LogLevel.debug:
          developer.log(logMessage, level: 500);
          break;
        case LogLevel.info:
          developer.log(logMessage, level: 800);
          break;
        case LogLevel.warning:
          developer.log(logMessage, level: 900);
          break;
        case LogLevel.error:
          developer.log(
            logMessage,
            level: 1000,
            error: error,
            stackTrace: stackTrace,
          );
          break;
        case LogLevel.fatal:
          developer.log(
            logMessage,
            level: 1200,
            error: error,
            stackTrace: stackTrace,
          );
          break;
      }
    }
  }
}

/// Extension for easy logging of AppErrors
extension AppErrorLogging on AppError {
  void log() {
    Logger.logError(this);
  }
}

/// Extension for easy logging of exceptions
extension ExceptionLogging on Exception {
  void log([String? context]) {
    final message = context != null ? '$context: $this' : toString();
    Logger.error(message, this, StackTrace.current);
  }
}
