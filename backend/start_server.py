#!/usr/bin/env python3
"""
WidMate Backend Server Startup Script

This script starts the FastAPI backend server with proper configuration.
"""

import os
import sys
import subprocess
from pathlib import Path

def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import fastapi
        import uvicorn
        import yt_dlp
        print("✅ All dependencies are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please install dependencies with: pip install -r requirements.txt")
        return False

def create_directories():
    """Create necessary directories"""
    directories = ['downloads', 'logs']
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
        print(f"📁 Created directory: {directory}")

def start_server(host="127.0.0.1", port=8000, reload=True):
    """Start the FastAPI server"""
    print(f"🚀 Starting WidMate Backend Server...")
    print(f"📡 Server will be available at: http://{host}:{port}")
    print(f"📚 API Documentation: http://{host}:{port}/docs")
    print(f"🔄 Auto-reload: {'Enabled' if reload else 'Disabled'}")
    print("-" * 50)
    
    try:
        import uvicorn
        uvicorn.run(
            "main:app",
            host=host,
            port=port,
            reload=reload,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")

def main():
    """Main function"""
    print("🎬 WidMate Video Downloader Backend")
    print("=" * 40)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Create directories
    create_directories()
    
    # Parse command line arguments
    host = "127.0.0.1"
    port = 8000
    reload = True
    
    if len(sys.argv) > 1:
        if "--host" in sys.argv:
            host_index = sys.argv.index("--host") + 1
            if host_index < len(sys.argv):
                host = sys.argv[host_index]
        
        if "--port" in sys.argv:
            port_index = sys.argv.index("--port") + 1
            if port_index < len(sys.argv):
                port = int(sys.argv[port_index])
        
        if "--no-reload" in sys.argv:
            reload = False
    
    # Start server
    start_server(host, port, reload)

if __name__ == "__main__":
    main()