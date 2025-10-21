import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';
import 'package:widmate/features/downloads/domain/services/download_service.dart';

final downloadEventsProvider = StreamProvider<DownloadEvent>((ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  return downloadService.downloadEvents;
});

final downloadProgressProvider = StreamProvider.family<double, String>((
  ref,
  downloadId,
) {
  final downloadService = ref.watch(downloadServiceProvider);
  return downloadService.downloadEvents
      .where(
        (event) =>
            event is DownloadProgressEvent && event.downloadId == downloadId,
      )
      .map((event) => (event as DownloadProgressEvent).progress);
});
