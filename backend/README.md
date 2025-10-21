# WidMate Backend Server

A FastAPI-based backend service for downloading videos using yt-dlp. This server provides RESTful APIs for video information extraction, download management, and progress tracking.

## Features

- 🎬 **Multi-platform Support**: YouTube, TikTok, Instagram, Facebook
- 📋 **Playlist Management**: Download entire playlists or select specific videos
- 🎯 **Quality Control**: Choose from 480p, 720p, 1080p, or audio-only
- 📊 **Progress Tracking**: Real-time download progress and status
- 🛡️ **Rate Limiting**: Built-in protection against abuse
- 📝 **Comprehensive Logging**: Detailed logs for debugging
- 🔄 **Background Processing**: Non-blocking download operations
- 📁 **File Management**: Secure file serving and cleanup

## Quick Start

### Prerequisites

- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. **Run the setup script** (Windows):
   ```bash
   setup.bat
   ```

2. **Or install manually**:
   ```bash
   pip install -r requirements.txt
   ```

### Starting the Server

1. **Using the start script** (Windows):
   ```bash
   start_backend.bat
   ```

2. **Or start manually**:
   ```bash
   python start_server.py
   ```

3. **Or use uvicorn directly**:
   ```bash
   uvicorn main:app --host 127.0.0.1 --port 8000 --reload
   ```

The server will be available at:
- **API Base URL**: http://127.0.0.1:8000
- **Interactive Documentation**: http://127.0.0.1:8000/docs
- **ReDoc Documentation**: http://127.0.0.1:8000/redoc

## API Endpoints

### 🔍 Get Video Information
```http
POST /info
Content-Type: application/json

{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "playlist_info": false
}
```

**Response:**
```json
{
  "id": "VIDEO_ID",
  "title": "Video Title",
  "description": "Video description...",
  "duration": 180,
  "thumbnail": "https://thumbnail-url.jpg",
  "uploader": "Channel Name",
  "formats": [
    {
      "format_id": "22",
      "ext": "mp4",
      "resolution": "1280x720",
      "quality": "720p"
    }
  ],
  "is_playlist": false
}
```

### ⬇️ Start Download
```http
POST /download
Content-Type: application/json

{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "quality": "720p",
  "audio_only": false,
  "playlist_items": "1-5"
}
```

**Response:**
```json
{
  "download_id": "uuid-string",
  "status": "pending",
  "message": "Download started"
}
```

### 📊 Check Download Status
```http
GET /status/{download_id}
```

**Response:**
```json
{
  "id": "uuid-string",
  "status": "downloading",
  "progress": 45.2,
  "speed": "1.2MB/s",
  "eta": "00:02:30",
  "downloaded_bytes": 15728640,
  "total_bytes": 34816000,
  "filename": "video_title.mp4"
}
```

### 📁 Download File
```http
GET /file/{download_id}
```

Returns the downloaded file as a binary stream.

### 📋 List All Downloads
```http
GET /downloads
```

### ❌ Cancel Download
```http
DELETE /download/{download_id}
```

### 🧹 Clear Completed Downloads
```http
DELETE /downloads
```

### 📈 System Statistics
```http
GET /system/stats
```

## Supported Platforms

| Platform | Single Video | Playlist | Audio Only | Max Quality |
|----------|--------------|----------|------------|-------------|
| YouTube | ✅ | ✅ | ✅ | 4K |
| TikTok | ✅ | ❌ | ✅ | 1080p |
| Instagram | ✅ | ❌ | ✅ | 1080p |
| Facebook | ✅ | ❌ | ✅ | 1080p |

## Quality Options

- **480p**: Standard definition
- **720p**: High definition (default)
- **1080p**: Full HD
- **audio-only**: Extract audio only

## Playlist Control

### Download Specific Items
```json
{
  "playlist_items": "1,3,5"  // Download items 1, 3, and 5
}
```

### Download Range
```json
{
  "playlist_items": "1-10"   // Download first 10 items
}
```

### Download All
```json
{
  "playlist_items": null     // Download entire playlist
}
```

## Error Handling

The API returns structured error responses:

```json
{
  "detail": "Error description",
  "status_code": 400
}
```

### Common Error Codes

- **400**: Bad Request (invalid URL, unsupported site)
- **404**: Resource not found (video, download)
- **429**: Rate limit exceeded
- **500**: Internal server error

## Rate Limiting

- **Info endpoint**: 30 requests per minute
- **Download endpoint**: 10 requests per minute
- **Other endpoints**: No specific limits

## Logging

Logs are stored in the `logs/` directory:
- **File**: `widmate_backend.log`
- **Rotation**: 10 MB per file
- **Retention**: 7 days

## Configuration

### Environment Variables

```bash
# Server configuration
HOST=127.0.0.1
PORT=8000

# Download settings
DOWNLOADS_DIR=downloads
MAX_CONCURRENT_DOWNLOADS=3

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/widmate_backend.log
```

### Custom yt-dlp Options

Modify the `get_ydl_opts()` function in `main.py` to customize yt-dlp behavior:

```python
def get_ydl_opts(download_id: str, quality: str = "720p", audio_only: bool = False):
    return {
        'format': format_selector,
        'outtmpl': output_template,
        'writeinfojson': True,
        'writesubtitles': True,  # Enable subtitles
        'writeautomaticsub': True,  # Enable auto-generated subtitles
        # Add more options as needed
    }
```

## Development

### Running in Development Mode

```bash
python start_server.py --host 0.0.0.0 --port 8000
```

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest tests/
```

### API Documentation

The server automatically generates interactive API documentation:

- **Swagger UI**: http://127.0.0.1:8000/docs
- **ReDoc**: http://127.0.0.1:8000/redoc
- **OpenAPI JSON**: http://127.0.0.1:8000/openapi.json

## Troubleshooting

### Common Issues

1. **"Python not found"**
   - Install Python 3.8+ from https://python.org
   - Ensure Python is added to PATH

2. **"Module not found"**
   - Run `pip install -r requirements.txt`
   - Check if you're in the correct directory

3. **"Port already in use"**
   - Change the port: `python start_server.py --port 8001`
   - Kill existing processes using the port

4. **"Download failed"**
   - Check the logs in `logs/widmate_backend.log`
   - Verify the URL is valid and supported
   - Check internet connection

5. **"Rate limit exceeded"**
   - Wait for the rate limit to reset
   - Reduce request frequency

### Debug Mode

Enable debug logging by setting the log level:

```python
logger.add("logs/debug.log", level="DEBUG")
```

## Security Considerations

- The server runs on localhost by default
- Rate limiting prevents abuse
- File access is restricted to download directory
- Input validation prevents injection attacks
- CORS is configured for development (adjust for production)

## Production Deployment

For production deployment:

1. **Use a production WSGI server**:
   ```bash
   pip install gunicorn
   gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
   ```

2. **Configure reverse proxy** (nginx, Apache)

3. **Set up SSL/TLS** for HTTPS

4. **Configure proper CORS** origins

5. **Set up monitoring** and log aggregation

6. **Use environment variables** for configuration

## License

This project is part of the WidMate application. Please refer to the main project license.

## Support

For issues and questions:
1. Check the logs in `logs/widmate_backend.log`
2. Review the API documentation at `/docs`
3. Ensure all dependencies are installed
4. Verify the URL format and platform support