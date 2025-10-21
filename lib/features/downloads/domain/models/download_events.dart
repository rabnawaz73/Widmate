import 'package:widmate/app/src/services/event_bus.dart';

abstract class DownloadEvent extends AppEvent {}

class DownloadStartedEvent extends DownloadEvent {
  final String downloadId;
  final String url;
  DownloadStartedEvent(this.downloadId, this.url);
}

class DownloadProgressEvent extends DownloadEvent {
  final String downloadId;
  final double progress;
  final int speed;
  final int eta;
  DownloadProgressEvent(this.downloadId, this.progress, this.speed, this.eta);
}

class DownloadCompletedEvent extends DownloadEvent {
  final String downloadId;
  final String filePath;
  DownloadCompletedEvent(this.downloadId, this.filePath);
}

class DownloadFailedEvent extends DownloadEvent {
  final String downloadId;
  final String error;
  DownloadFailedEvent(this.downloadId, this.error);
}

class DownloadPausedEvent extends DownloadEvent {
  final String downloadId;
  DownloadPausedEvent(this.downloadId);
}

class DownloadResumedEvent extends DownloadEvent {
  final String downloadId;
  DownloadResumedEvent(this.downloadId);
}

class DownloadCanceledEvent extends DownloadEvent {
  final String downloadId;
  DownloadCanceledEvent(this.downloadId);
}
