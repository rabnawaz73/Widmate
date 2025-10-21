import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/connectivity_service.dart';
import 'package:widmate/app/src/services/error_handler_service.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/app/src/services/logger_service.dart';
import 'package:widmate/app/src/services/notification_service.dart';

final providerScopes = [
  // Core services
  loggerProvider,
  eventBusProvider,
  errorHandlerProvider,
  notificationServiceProvider,
  connectivityServiceProvider,
  networkStatusProvider,

  // Feature providers
  // ...add your feature providers here...
];

class AppProviders {
  static List<Override> getOverrides() {
    return [
      // Add any provider overrides here
    ];
  }

  static List<ProviderObserver> getObservers() {
    return [
      LoggerService(),
    ];
  }
}