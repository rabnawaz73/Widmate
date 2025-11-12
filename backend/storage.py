import sqlite3
import os
from typing import Dict, Any

DB_PATH = os.getenv("DOWNLOAD_DB", "downloads.db")

def _init_db():
    conn = sqlite3.connect(DB_PATH)
    try:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS downloads (
                id TEXT PRIMARY KEY,
                url TEXT,
                status TEXT,
                progress REAL,
                speed TEXT,
                eta TEXT,
                downloaded_bytes INTEGER,
                total_bytes INTEGER,
                filename TEXT,
                error TEXT,
                created_at TEXT,
                updated_at TEXT
            )
            """
        )
        conn.commit()
    finally:
        conn.close()

def save_download_tasks(tasks: Dict[str, Any]):
    _init_db()
    conn = sqlite3.connect(DB_PATH)
    try:
        for t in tasks.values():
            conn.execute(
                """
                INSERT OR REPLACE INTO downloads (
                    id, url, status, progress, speed, eta, downloaded_bytes,
                    total_bytes, filename, error, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    t.get('id'),
                    t.get('url'),
                    t.get('status'),
                    float(t.get('progress', 0.0)),
                    t.get('speed'),
                    t.get('eta'),
                    int(t.get('downloaded_bytes', 0)),
                    t.get('total_bytes') if t.get('total_bytes') is not None else None,
                    t.get('filename'),
                    t.get('error'),
                    str(t.get('created_at')),
                    str(t.get('updated_at')),
                ),
            )
        conn.commit()
    finally:
        conn.close()

def load_download_tasks() -> Dict[str, Any]:
    _init_db()
    conn = sqlite3.connect(DB_PATH)
    try:
        rows = conn.execute("SELECT * FROM downloads").fetchall()
        tasks: Dict[str, Any] = {}
        for r in rows:
            task = {
                'id': r[0],
                'url': r[1],
                'status': r[2],
                'progress': float(r[3] or 0.0),
                'speed': r[4],
                'eta': r[5],
                'downloaded_bytes': int(r[6] or 0),
                'total_bytes': int(r[7]) if r[7] is not None else None,
                'filename': r[8],
                'error': r[9],
                'created_at': r[10],
                'updated_at': r[11],
            }
            tasks[task['id']] = task
        return tasks
    finally:
        conn.close()
