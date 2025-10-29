import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:widmate/app/src/router.dart';
import 'package:widmate/features/clipboard/presentation/managers/clipboard_overlay_manager.dart';
import 'package:widmate/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:widmate/app/src/theme.dart';
import 'package:widmate/app/src/localization/app_localizations.dart';
import 'package:widmate/core/widgets/app_icon_widget.dart';
import 'package:flutter/services.dart';
import 'package:widmate/core/providers/video_download_provider.dart';
import 'package:widmate/features/downloads/presentation/controllers/download_controller.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/app/src/providers/app_providers.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/features/settings/presentation/providers/theme_provider.dart';

final refreshProvider = StateProvider<int>((ref) => 0);

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clipboardOverlayManagerProvider(context));
    });

    final locale = ref.watch(appLocalizationsProvider.select((l) => l.locale));

    ref.listen(eventBusProvider, (previous, next) {
      next.on<ShowErrorEvent>().listen((event) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(event.message)),
        );
      });
    });

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'WidMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

class _RootScaffold extends ConsumerStatefulWidget {
  const _RootScaffold({required this.child});
  final Widget child;

  @override
  ConsumerState<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<_RootScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabAnimation;

  static const _pageTitles = [
    'Home',
    'Search',
    'Downloads',
    'Media',
    'Settings',
    'About',
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location;
    if (location.startsWith('/search')) {
      return 1;
    } else if (location.startsWith('/downloads')) {
      return 2;
    } else if (location.startsWith('/media')) {
      return 3;
    } else if (location.startsWith('/settings')) {
      return 4;
    } else if (location.startsWith('/about')) {
      return 5;
    } else {
      return 0;
    }
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/downloads');
        break;
      case 3:
        context.go('/media');
        break;
      case 4:
        context.go('/settings');
        break;
      case 5:
        context.go('/about');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, selectedIndex, widget.child),
      tablet: _buildTabletLayout(context, selectedIndex, widget.child),
      desktop: _buildDesktopLayout(context, selectedIndex, widget.child),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, int index, Widget child) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AppIconWidget(
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WidMate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _pageTitles[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(153), // 0.6 opacity
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (index == 0)
            IconButton(
              onPressed: () => _onDestinationSelected(1, context),
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  ref.read(refreshProvider.notifier).state++;
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
                case 'about':
                  _onDestinationSelected(5, context);
                  break;
              }
            },
            constraints: const BoxConstraints(minWidth: 180),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onDestinationSelected(i, context),
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Media',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
      floatingActionButton: index == 0
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final clipboardData =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  final url = clipboardData?.text;
                  if (url != null && Uri.tryParse(url)?.isAbsolute == true) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Getting video info...')),
                      );

                      final videoInfo =
                          await ref.read(videoInfoProvider(url).future);

                      if (videoInfo != null) {
                        final downloadResponse = await ref
                            .read(videoDownloadServiceProvider)
                            .startDownload(url: url);
                        final downloadId = downloadResponse.downloadId;

                        final platform = ref.read(platformDetectorProvider(url));
                        final downloadPlatform = platform != null
                            ? ref
                                .read(downloadControllerProvider.notifier)
                                .platformToDownloadPlatform(platform)
                            : DownloadPlatform.other;

                        await ref
                            .read(downloadControllerProvider.notifier)
                            .addDownload(
                              url: url,
                              title: videoInfo.title,
                              thumbnailUrl: videoInfo.thumbnail,
                              platform: downloadPlatform,
                              downloadId: downloadId,
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download started!')),
                        );
                        _onDestinationSelected(2, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not get video info.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to start download: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No valid URL found in clipboard.')),
                    );
                  }
                },
                icon: const Icon(Icons.content_paste),
                label: const Text('Quick Download'),
                tooltip: 'Download from clipboard',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabletLayout(
      BuildContext context, int index, Widget child) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => _onDestinationSelected(i, context),
            labelType: NavigationRailLabelType.selected,
            backgroundColor: colorScheme.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppIconWidget(
                        size: 32,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'WidMate - ${_pageTitles[index]}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (index == 0 || index == 2)
                        SearchBarWidget(
                          isExpanded: false,
                          onToggle: () {
                            _onDestinationSelected(1, context);
                          },
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'help') {
                            _showHelpDialog();
                          }
                        },
                        constraints: const BoxConstraints(minWidth: 180),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'help',
                            child: Row(
                              children: [
                                Icon(Icons.help_outline),
                                SizedBox(width: 8),
                                Text('Help'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, int index, Widget child) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => _onDestinationSelected(i, context),
            labelType: NavigationRailLabelType.all,
            backgroundColor: colorScheme.surface,
            minWidth: 200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppIconWidget(
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WidMate',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _pageTitles[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (index == 0 || index == 2)
                        Container(
                          width: 300,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _showHelpDialog,
                        icon: const Icon(Icons.help_outline),
                        tooltip: 'Help',
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.content_paste),
                        label: const Text('Quick Download'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 8),
              Text('Help & Tips'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How to use WidMate:', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  '1. Copy a video URL from YouTube, TikTok, Instagram, or Facebook',
                ),
                const SizedBox(height: 4),
                const Text('2. Paste it in the Home tab or use Quick Download'),
                const SizedBox(height: 4),
                const Text(
                  '3. Choose your preferred quality and start downloading',
                ),
                const SizedBox(height: 4),
                const Text('4. Monitor progress in the Downloads tab'),
                const SizedBox(height: 4),
                const Text('5. Access completed downloads in the History tab'),
                const SizedBox(height: 16),
                Text('Tips:', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('• Enable auto-detect clipboard in Settings'),
                const SizedBox(height: 4),
                const Text('• Use background downloads for large files'),
                const SizedBox(height: 4),
                const Text('• Adjust max concurrent downloads in Settings'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
