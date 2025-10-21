import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/shared_content/services/shared_content_service.dart';

// Provider for the SharedContentService
final sharedContentServiceProvider = Provider<SharedContentService>((ref) {
  return SharedContentService();
});