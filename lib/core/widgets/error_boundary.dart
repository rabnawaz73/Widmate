import 'package:flutter/material.dart';
import 'package:widmate/core/errors/app_errors.dart';

/// Error boundary widget that catches and displays errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppError error, VoidCallback onRetry)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _retry) ??
          _defaultErrorBuilder(_error!, _retry);
    }

    return widget.child;
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  Widget _defaultErrorBuilder(AppError error, VoidCallback onRetry) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Report error or show more details
                      _showErrorDetails(error);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetails(AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Message: ${error.message}'),
              if (error.code != null) ...[
                const SizedBox(height: 8),
                Text('Code: ${error.code}'),
              ],
              if (error.originalError != null) ...[
                const SizedBox(height: 8),
                Text('Original Error: ${error.originalError}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Error boundary for specific widgets
class WidgetErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(AppError error)? errorBuilder;

  const WidgetErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: (error, onRetry) =>
          errorBuilder?.call(error) ??
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  error.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
      child: child,
    );
  }
}

/// Extension for easy error boundary wrapping
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(AppError error, VoidCallback onRetry)? errorBuilder,
    VoidCallback? onError,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      child: this,
    );
  }
}
