import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:widmate/features/home/presentation/pages/home_page.dart';
import 'package:widmate/features/downloads/presentation/pages/downloads_page.dart';
import 'package:widmate/features/settings/presentation/pages/settings_page.dart';
import 'package:widmate/features/about/presentation/pages/about_page.dart';
import 'package:widmate/features/clipboard/presentation/managers/clipboard_overlay_manager.dart';
import 'package:widmate/features/search/presentation/pages/search_page.dart';
import 'package:widmate/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:widmate/features/media/presentation/pages/media_library_page.dart';
import 'package:widmate/app/src/theme.dart';
import 'package:widmate/app/src/localization/app_localizations.dart';
import 'package:widmate/core/widgets/app_icon_widget.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final pageNavigationRequestProvider =
    StateNotifierProvider<NavigationNotifier, int?>((ref) {
  return NavigationNotifier();
});

class NavigationNotifier extends StateNotifier<int?> {
  NavigationNotifier() : super(null);
  void setPage(int? page) => state = page;
}

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
    // Initialize clipboard overlay manager
    // This needs to be done after the app is built to have access to the overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clipboardOverlayManagerProvider(context));
    });

    // Get the current locale from the provider
    final locale = ref.watch(appLocalizationsProvider.select((l) => l.locale));

    final currentThemeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'WidMate',
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends ConsumerStatefulWidget {
  const _RootScaffold();

  @override
  ConsumerState<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<_RootScaffold>
    with TickerProviderStateMixin {
  int _index = 0;
  late final PageController _pageController;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabAnimation;

  static const _pages = <Widget>[
    HomePage(),
    SearchPage(),
    DownloadsPage(),
    MediaLibraryPage(),
    SettingsPage(),
    AboutPage(),
  ];

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
    _pageController = PageController();
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
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_index != index) {
      setState(() {
        _index = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTabletLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Rail
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onDestinationSelected,
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
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Compact AppBar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(51), // 0.2 opacity
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // App Logo
                      AppIconWidget(
                        size: 32,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'WidMate - ${_pageTitles[_index]}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Search and Menu
                      if (_index == 0 || _index == 2)
                        SearchBarWidget(
                          isExpanded: false,
                          onToggle: () {
                            // Navigate to search page
                            _pageController.animateToPage(
                              1, // Search page index
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'help':
                              _showHelpDialog();
                              break;
                          }
                        },
                        // Fix menu width
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
                // Page Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _index = index;
                      });
                    },
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // Extended Side Navigation
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onDestinationSelected,
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
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Desktop AppBar
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(51), // 0.2 opacity
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // App Logo and Title
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
                            _pageTitles[_index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(
                                179,
                              ), // 0.7 opacity
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Search Bar (for desktop)
                      if (_index == 0 || _index == 2)
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
                      // Action Buttons
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
                // Page Content with padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _index = index;
                        });
                      },
                      children: _pages,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(pageNavigationRequestProvider, (previous, next) {
      if (next != null) {
        _onDestinationSelected(next);
        // Reset the provider to allow subsequent navigation requests to the same page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(pageNavigationRequestProvider.notifier).setPage(null);
        });
      }
    });

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // App Logo
            AppIconWidget(
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),

            // App Name and Current Page
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
                  _pageTitles[_index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(153), // 0.6 opacity
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Search Action (visible on Home)
          if (_index == 0)
            IconButton(
              onPressed: () {
                // TODO: Implement search functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search functionality coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),

          // More Actions Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  // TODO: Implement refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refreshing...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
                case 'about':
                  setState(() {
                    _index = 3;
                  });
                  _pageController.animateToPage(
                    3,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  break;
              }
            },
            // Fix menu width
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _index = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
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
      floatingActionButton: _index == 0
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  // TODO: Implement quick download from clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quick download from clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
