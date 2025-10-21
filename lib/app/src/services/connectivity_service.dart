import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();

  StreamSubscription? _subscription;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged
        .map(_mapStatusList)
        .listen(_controller.add);
    _checkConnectivity();
  }

  Stream<NetworkStatus> get statusStream => _controller.stream;

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _controller.add(_mapStatusList(result));
  }

  NetworkStatus _mapStatusList(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    return NetworkStatus.online;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
