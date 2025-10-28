import json
from pathlib import Path
from typing import Dict, Any

DOWNLOAD_TASKS_FILE = Path("download_tasks.json")

def save_download_tasks(tasks: Dict[str, Any]):
    """Save download tasks to a file"""
    with open(DOWNLOAD_TASKS_FILE, "w") as f:
        json.dump(tasks, f, indent=4, default=str)

def load_download_tasks() -> Dict[str, Any]:
    """Load download tasks from a file"""
    if not DOWNLOAD_TASKS_FILE.exists():
        return {}
    with open(DOWNLOAD_TASKS_FILE, "r") as f:
        return json.load(f)
