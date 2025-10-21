import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:widmate/app/src/localization/l10n/messages_all.dart';

/// Provider for the current locale (scoped to localization module)
final appLocaleProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});

/// Provider for the AppLocalizations instance
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(appLocaleProvider);
  return AppLocalizations(locale);
});

/// Class that handles localization for the app
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Static method to get the current locale from the context using Riverpod
  static AppLocalizations fromRef(WidgetRef ref) {
    return ref.read(appLocalizationsProvider);
  }

  /// Static delegate for the localization
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    // Add more locales as needed
    // Locale('es'), // Spanish
    // Locale('fr'), // French
  ];

  /// Method to load the messages for the current locale
  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    // Initialize messages for the current locale
    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;
    return AppLocalizations(locale);
  }

  // *** LOCALIZED STRINGS ***

  // General
  String get appName => Intl.message(
    'WidMate',
    name: 'appName',
    desc: 'The name of the application',
  );

  String get loading => Intl.message(
    'Loading...',
    name: 'loading',
    desc: 'Text shown during loading operations',
  );

  String get error =>
      Intl.message('Error', name: 'error', desc: 'General error message');

  String get success =>
      Intl.message('Success', name: 'success', desc: 'General success message');

  String get cancel =>
      Intl.message('Cancel', name: 'cancel', desc: 'Cancel button text');

  String get save =>
      Intl.message('Save', name: 'save', desc: 'Save button text');

  String get ok => Intl.message('OK', name: 'ok', desc: 'OK button text');

  String get yes => Intl.message('Yes', name: 'yes', desc: 'Yes button text');

  String get no => Intl.message('No', name: 'no', desc: 'No button text');

  // Navigation
  String get homeTitle => Intl.message(
    'Home',
    name: 'homeTitle',
    desc: 'Title for the home screen',
  );

  String get downloadsTitle => Intl.message(
    'Downloads',
    name: 'downloadsTitle',
    desc: 'Title for the downloads screen',
  );

  String get settingsTitle => Intl.message(
    'Settings',
    name: 'settingsTitle',
    desc: 'Title for the settings screen',
  );

  String get aboutTitle => Intl.message(
    'About',
    name: 'aboutTitle',
    desc: 'Title for the about screen',
  );

  // Home Page
  String get enterUrl => Intl.message(
    'Enter URL',
    name: 'enterUrl',
    desc: 'Placeholder for URL input field',
  );

  String get download =>
      Intl.message('Download', name: 'download', desc: 'Download button text');

  String get invalidUrl => Intl.message(
    'Invalid URL',
    name: 'invalidUrl',
    desc: 'Error message for invalid URL',
  );

  // Downloads Page
  String get noDownloads => Intl.message(
    'No downloads yet',
    name: 'noDownloads',
    desc: 'Message shown when there are no downloads',
  );

  String get downloadComplete => Intl.message(
    'Download complete',
    name: 'downloadComplete',
    desc: 'Message shown when download is complete',
  );

  String get downloadFailed => Intl.message(
    'Download failed',
    name: 'downloadFailed',
    desc: 'Message shown when download fails',
  );

  String get downloadInProgress => Intl.message(
    'Downloading...',
    name: 'downloadInProgress',
    desc: 'Message shown when download is in progress',
  );

  // Settings Page
  String get generalSettings => Intl.message(
    'General Settings',
    name: 'generalSettings',
    desc: 'Title for general settings section',
  );

  String get downloadSettings => Intl.message(
    'Download Settings',
    name: 'downloadSettings',
    desc: 'Title for download settings section',
  );

  String get appearanceSettings => Intl.message(
    'Appearance',
    name: 'appearanceSettings',
    desc: 'Title for appearance settings section',
  );

  String get darkMode => Intl.message(
    'Dark Mode',
    name: 'darkMode',
    desc: 'Label for dark mode setting',
  );

  String get language => Intl.message(
    'Language',
    name: 'language',
    desc: 'Label for language setting',
  );

  String get downloadFolder => Intl.message(
    'Download Folder',
    name: 'downloadFolder',
    desc: 'Label for download folder setting',
  );

  String get concurrentDownloads => Intl.message(
    'Concurrent Downloads',
    name: 'concurrentDownloads',
    desc: 'Label for concurrent downloads setting',
  );

  // About Page
  String get version =>
      Intl.message('Version', name: 'version', desc: 'Label for app version');

  String get aboutDescription => Intl.message(
    'WidMate is a video downloader application for personal use only.',
    name: 'aboutDescription',
    desc: 'Description of the app in the about page',
  );

  String get disclaimer => Intl.message(
    'For personal use only. Do not use this application to download copyrighted content without permission.',
    name: 'disclaimer',
    desc: 'Legal disclaimer text',
  );

  // Clipboard detection
  String get videoLinkDetected => Intl.message(
    'Video link detected',
    name: 'videoLinkDetected',
    desc: 'Message shown when a video link is detected in clipboard',
  );

  String get downloadThisVideo => Intl.message(
    'Download this video?',
    name: 'downloadThisVideo',
    desc: 'Prompt asking if user wants to download detected video',
  );
}

/// Delegate for the localization
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}