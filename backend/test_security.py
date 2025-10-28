
import pytest
from fastapi.testclient import TestClient
from main import app, download_tasks, DOWNLOADS_DIR
import os
from pathlib import Path
import shutil

client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_and_teardown():
    # Setup: ensure downloads directory exists and is clean
    os.makedirs(DOWNLOADS_DIR, exist_ok=True)
    # Create a dummy file outside the download dir
    Path("test_secret_file.txt").write_text("this is a secret")
    yield
    # Teardown: clean up created files and directories
    if os.path.exists(DOWNLOADS_DIR):
        shutil.rmtree(DOWNLOADS_DIR)
    if os.path.exists("test_secret_file.txt"):
        os.remove("test_secret_file.txt")
    download_tasks.clear()

def test_path_traversal_vulnerability():
    # 1. Simulate a malicious download entry
    malicious_download_id = "malicious_download"
    # This filename attempts to traverse up from the 'downloads' directory
    malicious_filename = str(Path.cwd() / "test_secret_file.txt")

    download_tasks[malicious_download_id] = {
        'id': malicious_download_id,
        'status': 'completed',
        'filename': malicious_filename,
        'created_at': '2025-01-01T00:00:00',
        'updated_at': '2025-01-01T00:00:00'
    }

    # 2. Attempt to access the file using the vulnerable endpoint
    response = client.get(f"/file/{malicious_download_id}")

    # 3. Assert that the request was blocked (should be 404 or 403, not 200)
    assert response.status_code != 200, "Vulnerability exploited: Server returned a 200 OK status."
    assert "this is a secret" not in response.text, "Vulnerability exploited: Secret file content was exposed."
    
    # A secure implementation should return 404 Not Found
    assert response.status_code == 404, f"Expected 404 Not Found, but got {response.status_code}"
