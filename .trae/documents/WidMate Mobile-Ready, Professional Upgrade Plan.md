## Key Weak Points
- Local-only backend blocks mobile: `AppConstants.baseUrl` defaults to `http://127.0.0.1:8000` (lib/core/constants/app_constants.dart:18); Search uses hardcoded `http://localhost:8000` (lib/core/services/search_service.dart:5). This will fail on Android/iOS.
- Non-reactive base URL usage: services capture base URL at class load (`VideoDownloadService._baseUrl`, lib/core/services/video_download_service.dart:14), risking stale config after settings change.
- Background download duplication and low integration: Flutter-side `BackgroundDownloadService` not used by the main download flow (lib/features/downloads/domain/services/download_service.dart), while native Android/iOS services exist (android/app/src/main/kotlin/.../BackgroundDownloadService.kt, ios/Runner/BackgroundDownloadService.swift).
- Android storage permissions are legacy: uses `WRITE_EXTERNAL_STORAGE` (android/app/src/main/AndroidManifest.xml:4), incompatible with scoped storage on API 30+.
- Inefficient file save: `downloadFile` loads full response into memory (lib/core/services/video_download_service.dart:173–181), risking OOM for large files; should stream.
- Backend updater bugs: missing imports in auto_updater (`hashlib`, `os`) used at auto_updater.py:226/269.
- Backend concurrency and queueing: unbounded background tasks (backend/main.py:606–611), no `MAX_CONCURRENT_DOWNLOADS` enforcement.
- Security gaps: CORS allowlist is minimal (backend/main.py:92–103), no auth; path traversal handled (backend/main.py:651–657) good, but overall open API can be abused.
- UX/internationalization: only English localization (lib/app/src/localization/l10n/intl_en.arb); limited error surfacing and onboarding for backend connectivity.

## Objectives
- Make the app run reliably on Android and iOS without a local backend.
- Professional-grade performance, resilience, and UX for millions of users.
- Add missing features (remote backend discovery, resumable downloads, richer search, notifications) and harden security.

## Architecture Changes
- Add remote backend support with auto-discovery and fallback:
  - Introduce a `BackendConfig` provider that loads from settings, environment, or a remote discovery endpoint.
  - On startup, probe local backend; if unreachable, switch to a remote base URL.
  - Expose base URL change via Riverpod so services react at runtime.
- Centralize HTTP client:
  - Create a single `HttpClientService` that reads base URL from `baseUrlProvider` and is injected everywhere (replace `_baseUrl` constants).
- Event-driven progress:
  - Add Server-Sent Events or WebSocket `/events/{download_id}` to push progress from backend; Flutter listens via stream to reduce polling.

## Mobile Download Flow
- Keep yt-dlp extraction/download on backend; app fetches final files.
- Implement streaming file save with resume:
  - Use `http.Client.send` to stream into a file, write chunks, support `Range` for resuming.
  - Persist partial state; on retry, resume from last byte.
- Unify background downloads:
  - Remove unused native duplication OR wire the native services to consume backend file endpoints.
  - On Android, use scoped storage via `MediaStore` for public downloads; app-private storage for internal use.
  - On iOS, use `URLSessionDownloadTask` + background capabilities; keep files in app Documents or Photos on user request.

## Backend Enhancements
- Fix auto_updater imports and error handling.
- Enforce `MAX_CONCURRENT_DOWNLOADS` queue:
  - Maintain an asyncio/semaphore queue; cap active downloads; queue new ones.
- Add filename sanitization and respect `output_path` from `DownloadRequest`.
- Add HEAD/GET `/file/{id}` supporting `Range` for resumables; set `Content-Disposition` filename.
- Add `/health` and `/config` endpoints; include ffmpeg presence and versions.
- Optional auth: API key header with simple token list for remote deployments.
- Improve CORS to include mobile schemes and configurable origins.

## Performance & Reliability
- Stream saves; avoid large memory spikes.
- Retry with backoff in client for info/status/file; configure via settings.
- Cache video info and search results locally.
- Debounce clipboard detection; reduce battery consumption.

## UX & Professional Polish
- First-run onboarding to set backend URL or discover remote.
- Connectivity banner when backend unreachable; quick action to configure.
- Rich notifications with actions (pause/cancel/resume) wired to `DownloadService`.
- Multi-language: add ARB files for at least 5 languages and wire into UI.
- Accessibility: large text, high contrast modes; better focus states.

## Security & Compliance
- Explicit notice about platform terms and user responsibility; add settings for privacy.
- If deploying remote backend, add basic rate-limiting per IP/API key, and logging.
- Harden request validation; sanitize URLs.

## Testing & CI/CD
- Flutter unit/widget tests for services and pages; integration tests for downloads.
- Backend pytest coverage: rate limiting, queue, range serving, path traversal.
- GitHub Actions: build/test Flutter; build backend container; publish artifacts.

## Release Readiness
- App icons, splash, theming consistency.
- Versioning scheme; crash reporting (e.g., Sentry) with opt-in.
- Store submission considerations: Android likely OK with proper policy; iOS App Store may reject downloaders targeting YouTube—plan for enterprise/testflight distribution.

## Implementation Plan (Phased)
### Phase 1: Config & HTTP
- Replace hardcoded base URLs with provider-driven config across services:
  - Update `ApiService`, `VideoDownloadService`, `SearchService` to read `baseUrlProvider` at call time.
  - Create `HttpClientService` with interceptors, timeouts, and retry.
- Startup auto-detection and fallback:
  - Extend `AppInitializer` to probe local backend and switch to remote with persisted setting.

### Phase 2: Streaming & Resume
- Implement streaming save with `Range` in `VideoDownloadService.downloadFile`.
- Persist partial progress in repository; add resume/cancel flows.
- Backend: add `Range` support in `/file/{id}` and `Content-Disposition` header.

### Phase 3: Queue & Events
- Backend download queue with semaphore honoring `MAX_CONCURRENT_DOWNLOADS`.
- Add `/events/{id}` SSE for progress; client listens via a `StreamProvider`.
- Reduce polling timer or remove it for SSE.

### Phase 4: Mobile Storage & Background
- Android: migrate to scoped storage (MediaStore); request `POST_NOTIFICATIONS` only on Android 13+.
- iOS: ensure BGTask capability, test background downloads via `URLSessionDownloadTask`.
- Decide: either remove unused native background services or fully integrate them with backend flow.

### Phase 5: UX/Localization
- Add onboarding and connectivity UI.
- Add ARB translations and wire via `AppLocalizations`.
- Polish pages (Home, Search, Downloads, Settings) with consistent theming.

### Phase 6: Security & Ops
- Add API keys and configurable CORS.
- Add `/health` and `/config` endpoints; expose versions and capabilities.
- Logging and basic analytics with opt-in.

### Phase 7: Tests & CI
- Write unit/integration tests for new flows.
- Configure GitHub Actions for lint/test/build.

## Concrete File Targets
- Flutter:
  - lib/core/services/api_service.dart
  - lib/core/services/video_download_service.dart
  - lib/core/services/search_service.dart
  - lib/main.dart, lib/app/src/services/settings_service.dart
  - lib/features/downloads/domain/services/download_service.dart
- Backend:
  - backend/main.py (queue, range, headers)
  - backend/auto_updater.py (imports, robustness)
  - backend/storage.py (optional: task persistence improvements)

## Verification
- Run backend tests (pytest) and manual checks for info/download/status/file and range requests.
- Flutter: run widget/integration tests; manual end-to-end on Android & iOS simulators/devices.
- Measure memory during large file saves; confirm no OOM and proper resume after app kill.

If this plan looks good, I’ll proceed to implement Phase 1 changes first, then iterate through the phases with verification at each step.