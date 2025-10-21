import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widmate/app/app.dart';
import 'package:widmate/features/shared_content/services/shared_content_service.dart';
import 'package:widmate/features/downloads/domain/services/download_service.dart';
import 'package:widmate/features/clipboard/services/clipboard_monitor_service.dart';
import 'package:widmate/features/splash/presentation/pages/splash_screen.dart';
import 'package:widmate/core/services/background_download_service.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/features/media/domain/services/background_media_initializer.dart';

/// Riverpod provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Initialize in main'),
);

/// Observer to log provider updates
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    Logger.debug('[${provider.name ?? provider.runtimeType}] value: $newValue');
  }
}

/// A helper to safely initialize services without crashing the whole app
Future<void> safeInit(String name, Future<void> Function() initFn) async {
  try {
    await initFn();
    Logger.info('$name initialized');
  } catch (e, st) {
    Logger.error('Failed to initialize $name: $e\n$st');
  }
}

/// Handles app initialization logic
class AppInitializer {
  final ProviderContainer container;

  AppInitializer(this.container);

  Future<void> init() async {
    final downloadService = container.read(downloadServiceProvider);

    // Background downloads
    await safeInit('Background Download Service',
        () => container.read(backgroundDownloadServiceProvider).initialize());

    // Background media
    await safeInit('Background Media Service',
        () => BackgroundMediaInitializer.initialize());

    // Shared content
    final sharedContentService = SharedContentService();
    await safeInit('Shared Content Service', () async {
      await sharedContentService.init();
      sharedContentService.registerUrlHandler((url) {
        Logger.info('URL shared to app: $url');
        downloadService.addDownloadFromUrl(url).then((_) {
          Logger.info('Added shared URL to download queue: $url');
        }).catchError((error) {
          Logger.error('Error adding shared URL: $error');
        });
      });
    });

    // Clipboard monitoring
    final clipboardMonitorService = ClipboardMonitorService();
    await safeInit('Clipboard Monitor Service', () async {
      clipboardMonitorService.init();
      clipboardMonitorService.registerUrlHandler((url) {
        Logger.info('URL detected in clipboard: $url');
      });
    });
  }
}

Future<void> main() async {
  try {
    Logger.info('Starting WidMate application');
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    Logger.info('SharedPreferences initialized');

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      observers: [ProviderLogger()],
    );

    // Run the app with a splash that waits for services
    runApp(
      MaterialApp(
        home: ProviderScope(
          parent: container,
          child: SplashScreen(
            duration: const Duration(seconds: 3),
            nextScreen: FutureBuilder<void>(
              future: AppInitializer(container).init(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  final appError = ErrorFactory.fromException(
                    snapshot.error!,
                    snapshot.stackTrace,
                  );
                  appError.log();
                  return _ErrorScreen(appError: appError);
                }
                return const App();
              },
            ),
          ),
        ),
      ),
    );

    Logger.info('Application started successfully');
  } catch (e, stackTrace) {
    final appError = ErrorFactory.fromException(e, stackTrace);
    appError.log();

    runApp(MaterialApp(home: _ErrorScreen(appError: appError)));
  }
}

/// Improved error screen
class _ErrorScreen extends StatelessWidget {
  final AppError appError;
  const _ErrorScreen({required this.appError});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error initializing app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(appError.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: () => main(),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  runApp(const App()); // Start app without services
                },
                label: const Text('Continue Anyway'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add a global navigator key if needed for ProviderScope.containerOf
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
