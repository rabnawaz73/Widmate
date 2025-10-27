import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/services/api_service.dart'; // Assuming you have a general API service

final autoUpdaterProvider = StateNotifierProvider<AutoUpdaterNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AutoUpdaterNotifier(ref.read(apiServiceProvider));
});

class AutoUpdaterNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  AutoUpdaterNotifier(this._apiService) : super(const AsyncValue.loading()) {
    getStatus();
  }

  final ApiService _apiService;

  Future<void> getStatus() async {
    try {
      state = const AsyncValue.loading();
      final status = await _apiService.get('/auto-updater/status');
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

}
