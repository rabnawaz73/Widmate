import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';

/// Service for managing media files on device
class MediaFileService {
  static MediaFileService? _instance;
  static MediaFileService get instance => _instance ??= MediaFileService._();

  MediaFileService._();

  /// Get downloads directory
  Future<Directory> getDownloadsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(
        '${directory.path}/${AppConstants.downloadsFolder}',
      );

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      return downloadsDir;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      rethrow;
    }
  }

  /// Get all video files from downloads directory
  Future<List<MediaFile>> getDownloadedVideos() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      final videoFiles = <MediaFile>[];

      await for (final entity in downloadsDir.list(recursive: true)) {
        if (entity is File && _isVideoFile(entity.path)) {
          final mediaFile = await _createMediaFileFromFile(
            entity,
            MediaType.video,
          );
          if (mediaFile != null) {
            videoFiles.add(mediaFile);
          }
        }
      }

      // Sort by date modified (newest first)
      videoFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      Logger.info('Found ${videoFiles.length} downloaded videos');
      return videoFiles;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      return [];
    }
  }

  /// Get all audio files from downloads directory
  Future<List<MediaFile>> getDownloadedAudios() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      final audioFiles = <MediaFile>[];

      await for (final entity in downloadsDir.list(recursive: true)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final mediaFile = await _createMediaFileFromFile(
            entity,
            MediaType.audio,
          );
          if (mediaFile != null) {
            audioFiles.add(mediaFile);
          }
        }
      }

      // Sort by date modified (newest first)
      audioFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      Logger.info('Found ${audioFiles.length} downloaded audios');
      return audioFiles;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      return [];
    }
  }

  /// Get all media files from device storage
  Future<List<MediaFile>> getDeviceVideos() async {
    try {
      final videoFiles = <MediaFile>[];

      // Get common video directories
      final directories = await _getVideoDirectories();

      for (final directory in directories) {
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true)) {
            if (entity is File && _isVideoFile(entity.path)) {
              final mediaFile = await _createMediaFileFromFile(
                entity,
                MediaType.video,
              );
              if (mediaFile != null) {
                videoFiles.add(mediaFile);
              }
            }
          }
        }
      }

      // Sort by date modified (newest first)
      videoFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      Logger.info('Found ${videoFiles.length} device videos');
      return videoFiles;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      return [];
    }
  }

  /// Get all audio files from device storage
  Future<List<MediaFile>> getDeviceAudios() async {
    try {
      final audioFiles = <MediaFile>[];

      // Get common audio directories
      final directories = await _getAudioDirectories();

      for (final directory in directories) {
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true)) {
            if (entity is File && _isAudioFile(entity.path)) {
              final mediaFile = await _createMediaFileFromFile(
                entity,
                MediaType.audio,
              );
              if (mediaFile != null) {
                audioFiles.add(mediaFile);
              }
            }
          }
        }
      }

      // Sort by date modified (newest first)
      audioFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      Logger.info('Found ${audioFiles.length} device audios');
      return audioFiles;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      return [];
    }
  }

  /// Get common video directories
  Future<List<Directory>> _getVideoDirectories() async {
    final directories = <Directory>[];

    try {
      // Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      directories.add(downloadsDir);

      // DCIM directory (camera videos)
      final dcimDir = Directory('/storage/emulated/0/DCIM');
      if (await dcimDir.exists()) {
        directories.add(dcimDir);
      }

      // Movies directory
      final moviesDir = Directory('/storage/emulated/0/Movies');
      if (await moviesDir.exists()) {
        directories.add(moviesDir);
      }

      // WhatsApp videos
      final whatsappDir = Directory(
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Video',
      );
      if (await whatsappDir.exists()) {
        directories.add(whatsappDir);
      }

      // Telegram videos
      final telegramDir = Directory(
        '/storage/emulated/0/Telegram/Telegram Video',
      );
      if (await telegramDir.exists()) {
        directories.add(telegramDir);
      }
    } catch (e) {
      Logger.warning('Could not access some directories: $e');
    }

    return directories;
  }

  /// Get common audio directories
  Future<List<Directory>> _getAudioDirectories() async {
    final directories = <Directory>[];

    try {
      // Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      directories.add(downloadsDir);

      // Music directory
      final musicDir = Directory('/storage/emulated/0/Music');
      if (await musicDir.exists()) {
        directories.add(musicDir);
      }

      // WhatsApp audios
      final whatsappDir = Directory(
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
      );
      if (await whatsappDir.exists()) {
        directories.add(whatsappDir);
      }

      // Telegram audios
      final telegramDir = Directory(
        '/storage/emulated/0/Telegram/Telegram Audio',
      );
      if (await telegramDir.exists()) {
        directories.add(telegramDir);
      }
    } catch (e) {
      Logger.warning('Could not access some directories: $e');
    }

    return directories;
  }

  /// Check if file is a video file
  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return AppConstants.videoExtensions.contains('.$extension');
  }

  /// Check if file is an audio file
  bool _isAudioFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return AppConstants.audioExtensions.contains('.$extension');
  }

  /// Create MediaFile from File
  Future<MediaFile?> _createMediaFileFromFile(File file, MediaType type) async {
    try {
      final stat = await file.stat();
      final name = file.path.split('/').last;

      return MediaFile(
        path: file.path,
        name: name,
        type: type,
        size: stat.size,
        dateAdded: stat.accessed,
        dateModified: stat.modified,
        title: _extractTitleFromFileName(name),
        artist: 'Unknown Artist',
        album: 'Unknown Album',
      );
    } catch (e) {
      Logger.warning('Could not create MediaFile for ${file.path}: $e');
      return null;
    }
  }

  /// Extract title from filename
  String _extractTitleFromFileName(String fileName) {
    // Remove extension
    final nameWithoutExt = fileName.split('.').first;

    // Replace underscores and hyphens with spaces
    final cleanName = nameWithoutExt
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Capitalize first letter of each word
    return cleanName
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Delete media file
  Future<bool> deleteMediaFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        Logger.info('Deleted media file: $path');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      return false;
    }
  }

  /// Get file size
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
