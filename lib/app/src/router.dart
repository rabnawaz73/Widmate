import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/app.dart';
import 'package:widmate/features/home/presentation/pages/home_page.dart';
import 'package:widmate/features/downloads/presentation/pages/downloads_page.dart';
import 'package:widmate/features/about/presentation/pages/about_page.dart';
import 'package:widmate/features/search/presentation/pages/search_page.dart';
import 'package:widmate/features/media/presentation/pages/media_library_page.dart';
import 'package:widmate/features/settings/presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _RootScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchPage(),
            ),
          ),
          GoRoute(
            path: '/downloads',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DownloadsPage(),
            ),
          ),
          GoRoute(
            path: '/media',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MediaLibraryPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AboutPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
