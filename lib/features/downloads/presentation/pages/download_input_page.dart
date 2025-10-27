import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/models/download_models.dart';
import 'package:widmate/features/downloads/data/download_service.dart';

// Provider for the DownloadService
final downloadServiceProvider = Provider((ref) => DownloadService());

// State for the DownloadInputPage
class DownloadInputState {
  final String url;
  final bool isLoadingInfo;
  final VideoInfo? videoInfo;
  final String? selectedFormatId;
  final String? errorMessage;
  final bool isDownloading;

  DownloadInputState({
    this.url = '',
    this.isLoadingInfo = false,
    this.videoInfo,
    this.selectedFormatId,
    this.errorMessage,
    this.isDownloading = false,
  });

  DownloadInputState copyWith({
    String? url,
    bool? isLoadingInfo,
    VideoInfo? videoInfo,
    String? selectedFormatId,
    String? errorMessage,
    bool? isDownloading,
  }) {
    return DownloadInputState(
      url: url ?? this.url,
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      videoInfo: videoInfo ?? this.videoInfo,
      selectedFormatId: selectedFormatId ?? this.selectedFormatId,
      errorMessage: errorMessage,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

// StateNotifier for managing DownloadInputState
class DownloadInputController extends StateNotifier<DownloadInputState> {
  final DownloadService _downloadService;

  DownloadInputController(this._downloadService) : super(DownloadInputState());

  void setUrl(String url) {
    state = state.copyWith(url: url, errorMessage: null);
  }

  void setSelectedFormatId(String? formatId) {
    state = state.copyWith(selectedFormatId: formatId);
  }

  Future<void> fetchVideoInfo() async {
    if (state.url.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a URL');
      return;
    }

    state = state.copyWith(isLoadingInfo: true, videoInfo: null, errorMessage: null, selectedFormatId: null);
    try {
      final info = await _downloadService.getVideoInfo(state.url);
      state = state.copyWith(
        videoInfo: info,
        isLoadingInfo: false,
        selectedFormatId: info.formats.isNotEmpty ? info.formats.first.formatId : null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoadingInfo: false);
    }
  }

  Future<String?> startDownload() async {
    if (state.videoInfo == null || state.selectedFormatId == null) {
      state = state.copyWith(errorMessage: 'Please fetch video info and select a format');
      return null;
    }

    state = state.copyWith(isDownloading: true, errorMessage: null);
    try {
      final request = DownloadRequest(
        url: state.url,
        formatId: state.selectedFormatId,
      );
      final downloadStatus = await _downloadService.startDownload(request);
      state = state.copyWith(isDownloading: false);
      return downloadStatus.id; // Return download ID for tracking
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isDownloading: false);
      return null;
    }
  }
}

final downloadInputControllerProvider = StateNotifierProvider<DownloadInputController, DownloadInputState>((ref) {
  return DownloadInputController(ref.watch(downloadServiceProvider));
});

class DownloadInputPage extends ConsumerWidget {
  const DownloadInputPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadInputControllerProvider);
    final controller = ref.read(downloadInputControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Download Media')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: controller.setUrl,
              decoration: const InputDecoration(
                labelText: 'Video/Audio URL',
                hintText: 'Paste URL here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: state.isLoadingInfo || state.url.isEmpty ? null : controller.fetchVideoInfo,
              child: state.isLoadingInfo
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Video Info'),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (state.videoInfo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  Text(
                    state.videoInfo!.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (state.videoInfo!.thumbnail != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Image.network(state.videoInfo!.thumbnail!),
                    ),
                  Text(state.videoInfo!.description ?? 'No description'),
                  const SizedBox(height: 16.0),
                  if (state.videoInfo!.formats.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: state.selectedFormatId,
                      decoration: const InputDecoration(
                        labelText: 'Select Format',
                        border: OutlineInputBorder(),
                      ),
                      items: state.videoInfo!.formats.map((format) {
                        String label = '';
                        if (format.resolution != '0x0') {
                          label += '${format.resolution} ';
                        }
                        label += '${format.ext} ';
                        if (format.vcodec != null && format.vcodec != 'none') {
                          label += '(${format.vcodec}) ';
                        }
                        if (format.acodec != null && format.acodec != 'none') {
                          label += '(${format.acodec}) ';
                        }
                        if (format.filesize != null) {
                          label += ' - ${(format.filesize! / (1024 * 1024)).toStringAsFixed(2)} MB';
                        }
                        return DropdownMenuItem(
                          value: format.formatId,
                          child: Text(label.trim()),
                        );
                      }).toList(),
                      onChanged: controller.setSelectedFormatId,
                    ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: state.isDownloading || state.selectedFormatId == null
                        ? null
                        : () async {
                            final downloadId = await controller.startDownload();
                            if (downloadId != null) {
                              // Optionally navigate to downloads page or show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Download started: $downloadId')),
                              );
                              // TODO: Navigate to DownloadsPage or update UI to show progress
                            }
                          },
                    child: state.isDownloading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Start Download'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
