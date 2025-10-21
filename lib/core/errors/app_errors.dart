import 'package:widmate/core/constants/app_constants.dart';

/// Base class for all app errors
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message';
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    super.message = AppConstants.networkErrorMessage,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Server-related errors
class ServerError extends AppError {
  const ServerError({
    super.message = AppConstants.serverErrorMessage,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Download-related errors
class DownloadError extends AppError {
  const DownloadError({
    super.message = AppConstants.downloadFailedMessage,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Storage-related errors
class StorageError extends AppError {
  const StorageError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Permission-related errors
class PermissionError extends AppError {
  const PermissionError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Unknown errors
class UnknownError extends AppError {
  const UnknownError({
    super.message = AppConstants.unknownErrorMessage,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Error factory for creating appropriate error types
class ErrorFactory {
  static AppError fromException(dynamic exception, [StackTrace? stackTrace]) {
    if (exception is AppError) return exception;

    final message = exception.toString();

    // Network errors
    if (message.contains('SocketException') ||
        message.contains('HandshakeException') ||
        message.contains('TimeoutException')) {
      return NetworkError(originalError: exception, stackTrace: stackTrace);
    }

    // HTTP errors
    if (message.contains('HttpException') ||
        message.contains('ClientException')) {
      return ServerError(originalError: exception, stackTrace: stackTrace);
    }

    // Download errors
    if (message.contains('DownloadError') || message.contains('download')) {
      return DownloadError(originalError: exception, stackTrace: stackTrace);
    }

    // Validation errors
    if (message.contains('FormatException') ||
        message.contains('ArgumentError')) {
      return ValidationError(
        message: message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    // Storage errors
    if (message.contains('FileSystemException') ||
        message.contains('IOException')) {
      return StorageError(
        message: message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    // Permission errors
    if (message.contains('PermissionDeniedException') ||
        message.contains('permission')) {
      return PermissionError(
        message: message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    // Default to unknown error
    return UnknownError(originalError: exception, stackTrace: stackTrace);
  }

  static AppError networkError([String? message]) {
    return NetworkError(message: message ?? AppConstants.networkErrorMessage);
  }

  static AppError serverError([String? message]) {
    return ServerError(message: message ?? AppConstants.serverErrorMessage);
  }

  static AppError downloadError([String? message]) {
    return DownloadError(
      message: message ?? AppConstants.downloadFailedMessage,
    );
  }

  static AppError validationError(String message) {
    return ValidationError(message: message);
  }

  static AppError storageError(String message) {
    return StorageError(message: message);
  }

  static AppError permissionError(String message) {
    return PermissionError(message: message);
  }

  static AppError unknownError([String? message]) {
    return UnknownError(message: message ?? AppConstants.unknownErrorMessage);
  }
}
