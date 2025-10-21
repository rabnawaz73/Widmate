# WidMate

WidMate is a Flutter app with a local FastAPI backend for downloading videos from platforms like YouTube, TikTok, Instagram, and Facebook using yt-dlp. It supports background downloads, notifications, playlist ranges, and progress tracking.

## Features

- Video info lookup and download (single or playlist)
- Quality selection (480p/720p/1080p) and audio-only mode
- Background downloads with progress notifications
- Local file serving and history
- Clipboard detection and quick-paste UI

## Project Structure

- `lib/`: Flutter application (Riverpod 3, responsive UI, localization)
- `backend/`: FastAPI service that wraps yt-dlp
- `assets/`: App assets (icons)
- Platform folders: `android/`, `ios/`, `macos/`, `windows/`, `web/`
- Build scripts: PowerShell helpers for Android builds

## Prerequisites

- Flutter SDK (3.9.x Dart SDK)
- Android Studio/Xcode tooling as needed for your platform
- Python 3.8+ with pip (for backend)

## Backend: Setup & Run

Windows (recommended):

```bash
cd backend
setup.bat        # installs dependencies from requirements.txt
start_backend.bat
```

Manual:

```bash
cd backend
pip install -r requirements.txt
python start_server.py  # or: uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

Defaults:

- API Base URL: `http://127.0.0.1:8000`
- Docs: `http://127.0.0.1:8000/docs`

Environment (optional):

```bash
HOST=127.0.0.1
PORT=8000
DOWNLOADS_DIR=downloads
MAX_CONCURRENT_DOWNLOADS=3
LOG_LEVEL=INFO
```

## Frontend (Flutter): Setup & Run

```bash
flutter pub get
flutter run
```

Notes:

- Ensure the backend is running before using download functionality.
- If the backend host/port differs, update the app configuration/provider that defines the base URL.

## Key Endpoints (Backend)

- `POST /info` — extract video/playlist info
- `POST /download` — start a download (quality, audio_only, playlist_items)
- `GET /status/{download_id}` — progress and status
- `GET /file/{download_id}` — download the file
- `GET /downloads` — list; `DELETE /download/{id}` — cancel; `DELETE /downloads` — clear
- `GET /system/stats` — system stats

## Android/iOS Considerations

- Android: Notifications, foreground service, and storage permissions may be required.
- Background execution: Ensure battery optimizations are handled for stable background downloads.

## Scripts

- `build_apk_with_log.ps1`, `build_fixed_apk.ps1`, `fix_gradle.ps1` — helpers for Android builds.

## Troubleshooting

- Backend not reachable: verify it runs on `127.0.0.1:8000` and update app base URL if needed.
- Download failures: check `backend/logs/widmate_backend.log`.
- Port conflicts: run `python start_server.py --port 8001` and point the app to the new port.

## License

Part of the WidMate application.
