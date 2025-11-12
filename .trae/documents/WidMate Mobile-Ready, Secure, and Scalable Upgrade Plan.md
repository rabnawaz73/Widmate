## Critical Architecture Fixes

* Replace local-only backend assumption: make API base URL configurable at runtime with environment detection and settings UI; default to remote HTTPS.

* Unify base URL usage: refactor all clients to read `baseUrlProvider` instead of caching constants (`lib/core/services/video_download_service.dart:14`, `lib/core/services/api_service.dart:7`, `lib/core/services/search_service.dart:5`).

* Decide single download strategy: prefer backend-managed downloads with device pull of final file; remove or align native background services to avoid duplication.

## Backend Hardening & Bug Fixes

* Fix Python 3.8 compatibility: replace `Path.is_relative_to` in `backend/main.py:655` with a safe `startswith` check against resolved downloads dir.

* Add missing imports and errors in auto updater: import `hashlib` and `os` in `backend/auto_updater.py` and verify checksum flow.

* Correct `/info` payload handling: remove reference to non-existent `playlist_items` in `VideoInfoRequest` or add field consistently (`backend/main.py:481`).

* Normalize progress types to float and ensure consistent serialization for `created_at`/`updated_at` (`backend/main.py:241,249`).

* Consolidate rate limiting: use a single leaky-bucket per IP with limits per endpoint; add request IDs.

* Introduce simple auth (API key/JWT) with CORS whitelisting; add per-user quotas and cancellation.

* Persist tasks in SQLite (or LiteDB) instead of JSON (`backend/storage.py`), with proper locking and recovery.

## Mobile Platform Readiness

* Android: request `POST_NOTIFICATIONS` and battery optimization exemptions; review service boot and foreground flows (`android/app/src/main/kotlin/.../MainActivity.kt`, `BackgroundDownloadService.kt`).

* iOS: ensure BGTask identifiers and background modes are correct (`ios/Runner/Info.plist`); replace custom Objective-C/Swift downloader with unified approach.

* Replace or remove custom native downloaders unless used; otherwise, wire Flutter to pass full args (`fileName`, `filePath`, etc.) to prevent runtime errors (`BackgroundDownloadService.kt:141-148`).

## Performance & Scalability

* Replace polling with push updates: add WebSocket/SSE endpoint for progress and consume in Flutter.

* Add server-side concurrency controls and queueing (MAX\_CONCURRENT\_DOWNLOADS); support pause/resume via backend.

* Caching: memoize `/info` results per URL with TTL; cache search results; implement HTTP client timeouts and retries.

* Reduce large file limits: make `max_filesize` configurable (4–8GB) (`backend/main.py:229`).

## Feature Completeness & UX

* Unified Settings: base URL, default quality, clipboard detection, notifications, concurrency.

* Playlist ranges: expose friendly UI and map to backend `playlist_items`.

* Quality selection: show formats from `/info` and select `format_id` directly.

* Share-to-app: implement `receive_sharing_intent` and route shared URLs.

* Internationalization: add ARB files for at least 3 languages and localize all strings.

* Error handling: consistent user-facing messages and recovery actions; connectivity diagnostics page.

## Security & Compliance

* Input sanitization for URLs and search; validate domains; enforce TLS.

* Abuse protection: API keys, rate limits, per-user quotas; logging and audit trail.

* Legal disclaimer and terms; respect platform policies.

## Testing & Quality

* Backend: add pytest suite for endpoints (info/download/status/search, rate limit, path traversal).

* Frontend: unit tests for services/providers; integration test for download flow; widget tests for search and downloads.

* CI: lint, build, tests; static analysis.

## Deployment & DevOps

* Containerize backend (Docker) and provide Helm/docker-compose examples; env vars for scaling.

* Observability: structured logs, metrics, health checks; optional Sentry/Crashlytics on app.

* Release process: app versioning, changelogs, icons, splash, store metadata.

## Step-by-Step Implementation (first iteration)

1. Fix backend bugs (path traversal check, missing imports, payload mismatch) and normalize progress serialization.
2. Refactor Flutter services to use dynamic base URL via

