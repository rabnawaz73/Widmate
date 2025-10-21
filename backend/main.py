from fastapi import FastAPI, HTTPException, BackgroundTasks, Request, UploadFile, File
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import yt_dlp
import asyncio
import uuid
import os
import json
import time
from pathlib import Path
from loguru import logger
import psutil
import threading
from datetime import datetime
from collections import defaultdict
import time
import subprocess
import sys
import requests
import pkg_resources
from auto_updater import start_auto_updater, stop_auto_updater, get_auto_updater_status, configure_auto_updater, force_update_check, force_update

# Initialize FastAPI app
app = FastAPI(
    title="WidMate Video Downloader API",
    description="Backend service for downloading videos using yt-dlp",
    version="1.0.0"
)

# Initialize version info on startup
@app.on_event("startup")
async def startup_event():
    global version_info
    
    # Get current and latest versions
    current_version = get_current_ytdlp_version()
    latest_version = get_latest_ytdlp_version()
    
    # Update global state
    version_info["current_version"] = current_version
    version_info["latest_version"] = latest_version
    version_info["update_available"] = current_version != latest_version and latest_version != "unknown"
    version_info["last_check"] = time.time()
    
    logger.info(f"yt-dlp version check on startup: current={current_version}, latest={latest_version}")
    if version_info["update_available"]:
        logger.info(f"yt-dlp update available: {current_version} -> {latest_version}")
    else:
        logger.info(f"yt-dlp is up to date: {current_version}")
    
    # Start auto-updater service
    try:
        start_auto_updater()
        logger.info("Auto-updater service started")
    except Exception as e:
        logger.error(f"Failed to start auto-updater: {e}")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    try:
        stop_auto_updater()
        logger.info("Auto-updater service stopped")
    except Exception as e:
        logger.error(f"Error stopping auto-updater: {e}")

# Simple rate limiting storage
rate_limit_storage = defaultdict(list)
RATE_LIMIT_WINDOW = 60  # 1 minute
RATE_LIMIT_MAX_REQUESTS = 30

def check_rate_limit(client_ip: str, max_requests: int = RATE_LIMIT_MAX_REQUESTS) -> bool:
    """Simple rate limiting check"""
    now = time.time()
    # Clean old requests
    rate_limit_storage[client_ip] = [
        req_time for req_time in rate_limit_storage[client_ip]
        if now - req_time < RATE_LIMIT_WINDOW
    ]
    
    # Check if limit exceeded
    if len(rate_limit_storage[client_ip]) >= max_requests:
        return False
    
    # Add current request
    rate_limit_storage[client_ip].append(now)
    return True

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logger.add("logs/widmate_backend.log", rotation="10 MB", retention="7 days")

# Global storage for download tasks
download_tasks: Dict[str, Dict[str, Any]] = {}
download_lock = threading.Lock()

# Create directories
DOWNLOADS_DIR = Path("downloads")
LOGS_DIR = Path("logs")
DOWNLOADS_DIR.mkdir(exist_ok=True)
LOGS_DIR.mkdir(exist_ok=True)

# Pydantic models
class VideoInfoRequest(BaseModel):
    url: str
    playlist_info: bool = False

class DownloadRequest(BaseModel):
    url: str
    format_id: Optional[str] = "best"
    quality: Optional[str] = "720p"  # 480p, 720p, 1080p, audio-only
    playlist_items: Optional[str] = None  # "1-5" or "1,3,5" for specific items
    audio_only: bool = False
    output_path: Optional[str] = None
    
    class Config:
        schema_extra = {
            "example": {
                "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "quality": "720p",
                "audio_only": False
            }
        }

class DownloadStatus(BaseModel):
    id: str
    status: str  # pending, downloading, completed, failed, cancelled
    progress: float = 0.0
    speed: Optional[str] = None
    eta: Optional[str] = None
    downloaded_bytes: int = 0
    total_bytes: Optional[int] = None
    filename: Optional[str] = None
    error: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class VideoInfo(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    duration: Optional[int] = None
    thumbnail: Optional[str] = None
    uploader: Optional[str] = None
    upload_date: Optional[str] = None
    view_count: Optional[int] = None
    formats: List[Dict[str, Any]] = []
    is_playlist: bool = False
    playlist_count: Optional[int] = None
    playlist_entries: List[Dict[str, Any]] = []

class VersionInfo(BaseModel):
    current_version: str
    latest_version: str
    update_available: bool
    update_status: str = "idle"  # idle, downloading, installing, completed, failed
    update_progress: float = 0.0
    update_message: str = ""
    error: Optional[str] = None

class SearchRequest(BaseModel):
    query: str
    limit: int = 10

class SearchResult(BaseModel):
    id: str
    title: str
    description: str
    duration: Optional[int] = None
    thumbnail: Optional[str] = None
    uploader: Optional[str] = None
    upload_date: Optional[str] = None
    view_count: Optional[int] = None
    url: str
    webpage_url: str

class SearchResponse(BaseModel):
    query: str
    results: List[SearchResult]
    total: int
    search_time: float

# yt-dlp configuration
def get_ydl_opts(download_id: str, quality: str = "720p", audio_only: bool = False) -> Dict[str, Any]:
    """Get yt-dlp options based on quality preference"""
    
    output_template = str(DOWNLOADS_DIR / f"{download_id}_%(title)s.%(ext)s")
    
    if audio_only:
        format_selector = "bestaudio/best"
    else:
        quality_map = {
            "480p": "best[height<=480]",
            "720p": "best[height<=720]", 
            "1080p": "best[height<=1080]",
        }
        format_selector = quality_map.get(quality, "best")
    
    return {
        'format': format_selector,
        'outtmpl': output_template,
        'writeinfojson': True,
        'writesubtitles': False,
        'writeautomaticsub': False,
        'ignoreerrors': True,
        'no_warnings': False,
        'extractflat': False,
    }

def progress_hook(d: Dict[str, Any], download_id: str):
    """Progress hook for yt-dlp downloads"""
    with download_lock:
        if download_id not in download_tasks:
            return
            
        task = download_tasks[download_id]
        
        if d['status'] == 'downloading':
            task['status'] = 'downloading'
            task['progress'] = d.get('_percent_str', '0%').replace('%', '')
            task['speed'] = d.get('_speed_str', 'N/A')
            task['eta'] = d.get('_eta_str', 'N/A')
            task['downloaded_bytes'] = d.get('downloaded_bytes', 0)
            task['total_bytes'] = d.get('total_bytes', 0)
            
        elif d['status'] == 'finished':
            task['status'] = 'completed'
            task['progress'] = 100.0
            task['filename'] = d.get('filename', '')
            logger.info(f"Download completed: {download_id}")
            
        elif d['status'] == 'error':
            task['status'] = 'failed'
            task['error'] = str(d.get('error', 'Unknown error'))
            logger.error(f"Download failed: {download_id} - {task['error']}")
        
        task['updated_at'] = datetime.now()

def download_video_task(download_id: str, url: str, ydl_opts: Dict[str, Any]):
    """Background task to download video"""
    try:
        # Add progress hook
        ydl_opts['progress_hooks'] = [lambda d: progress_hook(d, download_id)]
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            logger.info(f"Starting download: {download_id} - {url}")
            ydl.download([url])
            
    except Exception as e:
        with download_lock:
            if download_id in download_tasks:
                download_tasks[download_id]['status'] = 'failed'
                download_tasks[download_id]['error'] = str(e)
                download_tasks[download_id]['updated_at'] = datetime.now()
        logger.error(f"Download error: {download_id} - {str(e)}")

# Global variable to store version check information
version_info = {
    "current_version": "",
    "latest_version": "",
    "update_available": False,
    "update_status": "idle",
    "update_progress": 0.0,
    "update_message": "",
    "error": None,
    "last_check": 0
}

def get_current_ytdlp_version() -> str:
    """Get the currently installed yt-dlp version"""
    try:
        return pkg_resources.get_distribution("yt-dlp").version
    except pkg_resources.DistributionNotFound:
        # Try using yt-dlp directly
        try:
            result = subprocess.run([sys.executable, "-m", "yt_dlp", "--version"], 
                                   capture_output=True, text=True, check=True)
            return result.stdout.strip()
        except subprocess.SubprocessError:
            logger.error("Failed to get yt-dlp version")
            return "unknown"

def get_latest_ytdlp_version() -> str:
    """Get the latest available yt-dlp version from PyPI"""
    try:
        response = requests.get("https://pypi.org/pypi/yt-dlp/json", timeout=10)
        response.raise_for_status()
        data = response.json()
        return data["info"]["version"]
    except (requests.RequestException, KeyError, json.JSONDecodeError) as e:
        logger.error(f"Failed to get latest yt-dlp version: {e}")
        return "unknown"

async def update_ytdlp(background_tasks: BackgroundTasks):
    """Update yt-dlp to the latest version"""
    global version_info
    
    # Already updating
    if version_info["update_status"] in ["downloading", "installing"]:
        return
    
    version_info["update_status"] = "downloading"
    version_info["update_progress"] = 0.0
    version_info["update_message"] = "Downloading update..."
    version_info["error"] = None
    
    def do_update():
        global version_info
        try:
            # Update progress for UI
            version_info["update_progress"] = 0.2
            version_info["update_message"] = "Preparing to update..."
            
            # Use pip to update yt-dlp
            version_info["update_progress"] = 0.4
            version_info["update_message"] = "Installing update..."
            
            result = subprocess.run(
                [sys.executable, "-m", "pip", "install", "--upgrade", "yt-dlp"],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                logger.error(f"Failed to update yt-dlp: {result.stderr}")
                version_info["update_status"] = "failed"
                version_info["error"] = f"Update failed: {result.stderr}"
                return
            
            # Update progress
            version_info["update_progress"] = 0.8
            version_info["update_message"] = "Optimizing performance..."
            time.sleep(1)  # Give a moment for UI to show progress
            
            # Get the new version
            new_version = get_current_ytdlp_version()
            version_info["current_version"] = new_version
            version_info["update_progress"] = 1.0
            version_info["update_message"] = f"Successfully updated to version {new_version}"
            version_info["update_status"] = "completed"
            logger.info(f"Successfully updated yt-dlp to version {new_version}")
            
        except Exception as e:
            logger.error(f"Error during yt-dlp update: {e}")
            version_info["update_status"] = "failed"
            version_info["error"] = str(e)
    
    # Run the update in the background
    background_tasks.add_task(do_update)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "WidMate Video Downloader API",
        "version": "1.0.0",
        "status": "running",
        "active_downloads": len([t for t in download_tasks.values() if t['status'] == 'downloading'])
    }

@app.get("/version/check", response_model=VersionInfo)
async def check_version(request: Request, force: bool = False):
    """Check for yt-dlp updates"""
    global version_info
    
    # Rate limiting
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 10):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    # Only check once every 30 minutes unless forced
    current_time = time.time()
    if not force and current_time - version_info["last_check"] < 1800:  # 30 minutes
        return VersionInfo(
            current_version=version_info["current_version"],
            latest_version=version_info["latest_version"],
            update_available=version_info["update_available"],
            update_status=version_info["update_status"],
            update_progress=version_info["update_progress"],
            update_message=version_info["update_message"],
            error=version_info["error"]
        )
    
    # Get current and latest versions
    current_version = get_current_ytdlp_version()
    latest_version = get_latest_ytdlp_version()
    
    # Update global state
    version_info["current_version"] = current_version
    version_info["latest_version"] = latest_version
    version_info["update_available"] = current_version != latest_version and latest_version != "unknown"
    version_info["last_check"] = current_time
    
    logger.info(f"Version check: current={current_version}, latest={latest_version}, update_available={version_info['update_available']}")
    
    return VersionInfo(
        current_version=current_version,
        latest_version=latest_version,
        update_available=version_info["update_available"],
        update_status=version_info["update_status"],
        update_progress=version_info["update_progress"],
        update_message=version_info["update_message"],
        error=version_info["error"]
    )

@app.post("/version/update")
async def update_version(request: Request, background_tasks: BackgroundTasks):
    """Update yt-dlp to the latest version"""
    global version_info
    
    # Rate limiting
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 5):  # Stricter rate limit for updates
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    # Check if update is needed
    if not version_info["update_available"]:
        return {"message": "Already up to date"}
    
    # Check if already updating
    if version_info["update_status"] in ["downloading", "installing"]:
        return {"message": "Update already in progress", "status": version_info["update_status"]}
    
    # Start update process
    await update_ytdlp(background_tasks)
    
    return {
        "message": "Update started",
        "status": version_info["update_status"],
        "progress": version_info["update_progress"]
    }

@app.get("/version/status", response_model=VersionInfo)
async def get_update_status():
    """Get the current status of yt-dlp update"""
    global version_info
    
    return VersionInfo(
        current_version=version_info["current_version"],
        latest_version=version_info["latest_version"],
        update_available=version_info["update_available"],
        update_status=version_info["update_status"],
        update_progress=version_info["update_progress"],
        update_message=version_info["update_message"],
        error=version_info["error"]
    )

@app.post("/info")
async def get_video_info(request: Request, video_request: VideoInfoRequest) -> VideoInfo:
    # Rate limiting
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 30):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    """Get video metadata and available formats"""
    try:
        logger.info(f"Getting info for: {video_request.url}")
        
        ydl_opts = {
            'quiet': True,
            'no_warnings': True,
            'extractflat': video_request.playlist_info,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_request.url, download=False)
            
            if not info:
                raise HTTPException(status_code=404, detail="Video not found or URL invalid")
            
            # Handle playlist
            if 'entries' in info:
                playlist_entries = []
                for i, entry in enumerate(info['entries'][:50]):  # Limit to first 50 entries
                    if entry:
                        playlist_entries.append({
                            'index': i + 1,
                            'id': entry.get('id', ''),
                            'title': entry.get('title', 'Unknown'),
                            'duration': entry.get('duration'),
                            'thumbnail': entry.get('thumbnail'),
                            'url': entry.get('webpage_url', entry.get('url', ''))
                        })
                
                return VideoInfo(
                    id=info.get('id', ''),
                    title=info.get('title', 'Unknown Playlist'),
                    description=info.get('description', ''),
                    duration=None,
                    thumbnail=info.get('thumbnail'),
                    uploader=info.get('uploader', ''),
                    upload_date=info.get('upload_date', ''),
                    view_count=info.get('view_count'),
                    formats=[],
                    is_playlist=True,
                    playlist_count=len(playlist_entries),
                    playlist_entries=playlist_entries
                )
            
            # Handle single video
            formats = []
            if 'formats' in info:
                for fmt in info['formats']:
                    if fmt.get('vcodec') != 'none':  # Video formats
                        formats.append({
                            'format_id': fmt.get('format_id', ''),
                            'ext': fmt.get('ext', ''),
                            'resolution': f"{fmt.get('width', 0)}x{fmt.get('height', 0)}",
                            'fps': fmt.get('fps'),
                            'filesize': fmt.get('filesize'),
                            'quality': fmt.get('format_note', ''),
                            'vcodec': fmt.get('vcodec', ''),
                            'acodec': fmt.get('acodec', ''),
                        })
            
            return VideoInfo(
                id=info.get('id', ''),
                title=info.get('title', 'Unknown'),
                description=info.get('description', ''),
                duration=info.get('duration'),
                thumbnail=info.get('thumbnail'),
                uploader=info.get('uploader', ''),
                upload_date=info.get('upload_date', ''),
                view_count=info.get('view_count'),
                formats=formats,
                is_playlist=False,
                playlist_count=None,
                playlist_entries=[]
            )
            
    except yt_dlp.DownloadError as e:
        logger.error(f"yt-dlp error: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Download error: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.post("/download")
async def start_download(request: Request, download_request: DownloadRequest, background_tasks: BackgroundTasks) -> Dict[str, str]:
    # Rate limiting
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 10):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    """Start video download"""
    try:
        download_id = str(uuid.uuid4())
        
        # Create download task entry
        with download_lock:
            download_tasks[download_id] = {
                'id': download_id,
                'url': download_request.url,
                'status': 'pending',
                'progress': 0.0,
                'speed': None,
                'eta': None,
                'downloaded_bytes': 0,
                'total_bytes': None,
                'filename': None,
                'error': None,
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
        
        # Get yt-dlp options
        ydl_opts = get_ydl_opts(
            download_id, 
            download_request.quality, 
            download_request.audio_only
        )
        
        # Add playlist items filter if specified
        if download_request.playlist_items:
            ydl_opts['playlist_items'] = download_request.playlist_items
        
        # Start download in background
        background_tasks.add_task(
            download_video_task,
            download_id,
            download_request.url,
            ydl_opts
        )
        
        logger.info(f"Download queued: {download_id}")
        
        return {
            "download_id": download_id,
            "status": "pending",
            "message": "Download started"
        }
        
    except Exception as e:
        logger.error(f"Error starting download: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to start download: {str(e)}")

@app.get("/status/{download_id}")
async def get_download_status(download_id: str) -> DownloadStatus:
    """Get download progress and status"""
    with download_lock:
        if download_id not in download_tasks:
            raise HTTPException(status_code=404, detail="Download not found")
        
        task = download_tasks[download_id]
        return DownloadStatus(**task)

@app.get("/file/{download_id}")
async def get_downloaded_file(download_id: str):
    """Download the completed file"""
    with download_lock:
        if download_id not in download_tasks:
            raise HTTPException(status_code=404, detail="Download not found")
        
        task = download_tasks[download_id]
        
        if task['status'] != 'completed':
            raise HTTPException(status_code=400, detail="Download not completed")
        
        filename = task.get('filename')
        if not filename or not os.path.exists(filename):
            raise HTTPException(status_code=404, detail="File not found")
        
        return FileResponse(
            path=filename,
            filename=os.path.basename(filename),
            media_type='application/octet-stream'
        )

@app.delete("/download/{download_id}")
async def cancel_download(download_id: str) -> Dict[str, str]:
    """Cancel an active download"""
    with download_lock:
        if download_id not in download_tasks:
            raise HTTPException(status_code=404, detail="Download not found")
        
        task = download_tasks[download_id]
        
        if task['status'] in ['completed', 'failed', 'cancelled']:
            raise HTTPException(status_code=400, detail="Download cannot be cancelled")
        
        task['status'] = 'cancelled'
        task['updated_at'] = datetime.now()
        
        logger.info(f"Download cancelled: {download_id}")
        
        return {
            "download_id": download_id,
            "status": "cancelled",
            "message": "Download cancelled"
        }

@app.get("/downloads")
async def list_downloads() -> List[DownloadStatus]:
    """List all downloads"""
    with download_lock:
        return [DownloadStatus(**task) for task in download_tasks.values()]

@app.delete("/downloads")
async def clear_downloads() -> Dict[str, str]:
    """Clear completed and failed downloads"""
    with download_lock:
        to_remove = []
        for download_id, task in download_tasks.items():
            if task['status'] in ['completed', 'failed', 'cancelled']:
                to_remove.append(download_id)
        
        for download_id in to_remove:
            del download_tasks[download_id]
        
        logger.info(f"Cleared {len(to_remove)} downloads")
        
        return {
            "message": f"Cleared {len(to_remove)} downloads",
            "cleared_count": len(to_remove)
        }

@app.get("/system/stats")
async def get_system_stats() -> Dict[str, Any]:
    """Get system statistics"""
    return {
        "cpu_percent": psutil.cpu_percent(),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_usage": {
            "total": psutil.disk_usage('/').total,
            "used": psutil.disk_usage('/').used,
            "free": psutil.disk_usage('/').free,
        },
        "active_downloads": len([t for t in download_tasks.values() if t['status'] == 'downloading']),
        "total_downloads": len(download_tasks)
    }

# Auto-updater management endpoints
@app.get("/auto-updater/status")
async def get_auto_updater_status():
    """Get auto-updater status and configuration"""
    return get_auto_updater_status()

@app.post("/auto-updater/configure")
async def configure_auto_updater_endpoint(request: Request, config: Dict[str, Any]):
    """Configure auto-updater settings"""
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 5):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    try:
        configure_auto_updater(**config)
        return {"message": "Auto-updater configuration updated", "config": config}
    except Exception as e:
        logger.error(f"Failed to configure auto-updater: {e}")
        raise HTTPException(status_code=500, detail=f"Configuration failed: {e}")

@app.post("/auto-updater/check")
async def force_update_check_endpoint(request: Request):
    """Force an immediate update check"""
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 3):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    try:
        force_update_check()
        return {"message": "Update check triggered"}
    except Exception as e:
        logger.error(f"Failed to trigger update check: {e}")
        raise HTTPException(status_code=500, detail=f"Update check failed: {e}")

@app.post("/auto-updater/update")
async def force_update_endpoint(request: Request):
    """Force an immediate update"""
    client_ip = request.client.host if request.client else "unknown"
    if not check_rate_limit(client_ip, 2):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    try:
        force_update()
        return {"message": "Update triggered"}
    except Exception as e:
        logger.error(f"Failed to trigger update: {e}")
        raise HTTPException(status_code=500, detail=f"Update failed: {e}")

@app.post("/search", response_model=SearchResponse)
async def search_videos(request: Request, search_request: SearchRequest) -> SearchResponse:
    """Search for videos using yt-dlp"""
    start_time = time.time()
    
    try:
        # Rate limiting
        client_ip = request.client.host
        current_time = time.time()
        
        if client_ip in rate_limiter:
            if current_time - rate_limiter[client_ip] < 1:  # 1 second between requests
                raise HTTPException(status_code=429, detail="Rate limit exceeded")
        
        rate_limiter[client_ip] = current_time
        
        # Configure yt-dlp for search
        ydl_opts = {
            'quiet': True,
            'no_warnings': True,
            'extract_flat': True,
            'default_search': f'ytsearch{search_request.limit}',
        }
        
        search_results = []
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Search for videos
            search_query = f"ytsearch{search_request.limit}:{search_request.query}"
            info = ydl.extract_info(search_query, download=False)
            
            if info and 'entries' in info:
                for entry in info['entries']:
                    if entry:  # Skip None entries
                        search_results.append(SearchResult(
                            id=entry.get('id', ''),
                            title=entry.get('title', 'Unknown'),
                            description=entry.get('description', ''),
                            duration=entry.get('duration'),
                            thumbnail=entry.get('thumbnail'),
                            uploader=entry.get('uploader', ''),
                            upload_date=entry.get('upload_date', ''),
                            view_count=entry.get('view_count'),
                            url=entry.get('url', ''),
                            webpage_url=entry.get('webpage_url', entry.get('url', ''))
                        ))
        
        search_time = time.time() - start_time
        
        return SearchResponse(
            query=search_request.query,
            results=search_results,
            total=len(search_results),
            search_time=search_time
        )
        
    except yt_dlp.DownloadError as e:
        logger.error(f"Search error: {e}")
        raise HTTPException(status_code=400, detail=f"Search failed: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected search error: {e}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")