import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final storageInfoProvider = FutureProvider<AppStorageInfo>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getStorageInfo();
});

class StorageManagementWidget extends ConsumerWidget {
  const StorageManagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageInfoAsync = ref.watch(storageInfoProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Storage Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.refresh(storageInfoProvider),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh storage info',
                ),
              ],
            ),
            const SizedBox(height: 16),

            storageInfoAsync.when(
              data: (storageInfo) => _buildStorageInfo(context, storageInfo),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error loading storage info: $error',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _clearCache(context, ref),
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clear Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _clearOldCache(context, ref),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Clear Old Files'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context, AppStorageInfo storageInfo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildStorageItem(
          context,
          'Cache',
          storageInfo.formattedCacheSize,
          Icons.cached,
          colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildStorageItem(
          context,
          'Downloads',
          storageInfo.formattedDownloadsSize,
          Icons.download,
          colorScheme.secondary,
        ),
        const Divider(height: 16),
        _buildStorageItem(
          context,
          'Total',
          storageInfo.formattedTotalSize,
          Icons.storage,
          colorScheme.tertiary,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildStorageItem(
    BuildContext context,
    String label,
    String size,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final textStyle = isTotal
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Row(
      children: [
        Icon(icon, color: color, size: isTotal ? 20 : 16),
        const SizedBox(width: 8),
        Text(label, style: textStyle),
        const Spacer(),
        Text(size, style: textStyle?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final storageService = ref.read(storageServiceProvider);
      final success = await storageService.clearCache();

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.invalidate(storageInfoProvider);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to clear cache'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error clearing cache: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearOldCache(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final storageService = ref.read(storageServiceProvider);
      final success = await storageService.clearOldCache(olderThanDays: 7);

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Old cache files cleared successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.invalidate(storageInfoProvider);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to clear old cache files'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error clearing old cache: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
