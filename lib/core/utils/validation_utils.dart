import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';

/// Utility class for input validation
class ValidationUtils {
  ValidationUtils._();

  /// Validates if a string is a valid URL
  static ValidationResult validateUrl(String url) {
    if (url.isEmpty) {
      return ValidationResult.error('URL cannot be empty');
    }

    if (url.length < AppConstants.minUrlLength) {
      return ValidationResult.error('URL is too short');
    }

    if (url.length > AppConstants.maxUrlLength) {
      return ValidationResult.error('URL is too long');
    }

    try {
      final uri = Uri.parse(url);

      if (!uri.hasScheme) {
        return ValidationResult.error('URL must include protocol (http/https)');
      }

      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return ValidationResult.error(
          'Only HTTP and HTTPS protocols are supported',
        );
      }

      if (!uri.hasAuthority) {
        return ValidationResult.error('URL must include domain');
      }

      // Check for common video platform patterns
      final host = uri.host.toLowerCase();
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return ValidationResult.success(url, 'YouTube URL detected');
      } else if (host.contains('tiktok.com')) {
        return ValidationResult.success(url, 'TikTok URL detected');
      } else if (host.contains('instagram.com')) {
        return ValidationResult.success(url, 'Instagram URL detected');
      } else if (host.contains('facebook.com') || host.contains('fb.com')) {
        return ValidationResult.success(url, 'Facebook URL detected');
      } else {
        return ValidationResult.success(url, 'Generic URL detected');
      }
    } catch (e) {
      return ValidationResult.error('Invalid URL format');
    }
  }

  /// Validates search query
  static ValidationResult validateSearchQuery(String query) {
    if (query.isEmpty) {
      return ValidationResult.error('Search query cannot be empty');
    }

    if (query.length < 2) {
      return ValidationResult.error(
        'Search query must be at least 2 characters',
      );
    }

    if (query.length > 100) {
      return ValidationResult.error('Search query is too long');
    }

    // Check for potentially harmful content
    if (query.contains('<script>') || query.contains('javascript:')) {
      return ValidationResult.error('Invalid characters in search query');
    }

    return ValidationResult.success(query.trim());
  }

  /// Validates title
  static ValidationResult validateTitle(String title) {
    if (title.isEmpty) {
      return ValidationResult.error('Title cannot be empty');
    }

    if (title.length > AppConstants.maxTitleLength) {
      return ValidationResult.error('Title is too long');
    }

    return ValidationResult.success(title.trim());
  }

  /// Validates description
  static ValidationResult validateDescription(String description) {
    if (description.length > AppConstants.maxDescriptionLength) {
      return ValidationResult.error('Description is too long');
    }

    return ValidationResult.success(description.trim());
  }

  /// Validates file path
  static ValidationResult validateFilePath(String filePath) {
    if (filePath.isEmpty) {
      return ValidationResult.error('File path cannot be empty');
    }

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(filePath)) {
      return ValidationResult.error('File path contains invalid characters');
    }

    return ValidationResult.success(filePath);
  }

  /// Validates quality setting
  static ValidationResult validateQuality(String quality) {
    if (!AppConstants.qualityOptions.contains(quality)) {
      return ValidationResult.error('Invalid quality setting');
    }

    return ValidationResult.success(quality);
  }

  /// Validates concurrent downloads count
  static ValidationResult validateConcurrentDownloads(int count) {
    if (count < 1) {
      return ValidationResult.error('Concurrent downloads must be at least 1');
    }

    if (count > 10) {
      return ValidationResult.error('Concurrent downloads cannot exceed 10');
    }

    return ValidationResult.success(count.toString());
  }

  /// Sanitizes filename
  static String sanitizeFilename(String filename) {
    // Remove invalid characters
    final sanitized = filename.replaceAll(RegExp(r'[<>:"|?*\\/]'), '_');

    // Remove multiple underscores
    final cleaned = sanitized.replaceAll(RegExp(r'_+'), '_');

    // Remove leading/trailing underscores
    return cleaned.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Checks if string is a valid email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Checks if string is a valid phone number
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final String? value;
  final String? error;
  final String? info;

  const ValidationResult._({
    required this.isValid,
    this.value,
    this.error,
    this.info,
  });

  factory ValidationResult.success(String value, [String? info]) {
    return ValidationResult._(isValid: true, value: value, info: info);
  }

  factory ValidationResult.error(String error) {
    return ValidationResult._(isValid: false, error: error);
  }

  /// Throws ValidationError if validation failed
  void throwIfInvalid() {
    if (!isValid) {
      throw ValidationError(message: error!);
    }
  }
}
