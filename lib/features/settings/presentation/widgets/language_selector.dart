import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/localization/app_localizations.dart';

/// Widget for selecting the application language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleProvider);
    final localizations = AppLocalizations.of(context);

    return ListTile(
      title: Text(localizations.language),
      subtitle: Text(_getLanguageName(currentLocale.languageCode)),
      trailing: const Icon(Icons.language),
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  /// Shows a dialog for selecting the language
  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final currentLocale = ref.read(appLocaleProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocalizations.supportedLocales.map((locale) {
              return ListTile(
                title: Text(_getLanguageName(locale.languageCode)),
                trailing: currentLocale.languageCode == locale.languageCode
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(appLocaleProvider.notifier).state = locale;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  /// Returns the display name for a language code
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      // Add more languages as needed
      // case 'es':
      //   return 'Español';
      // case 'fr':
      //   return 'Français';
      default:
        return languageCode;
    }
  }
}