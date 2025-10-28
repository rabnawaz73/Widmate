import sys
import subprocess

if __name__ == "__main__":
    result = subprocess.run([sys.executable, "-m", "pytest", "backend/test_security.py"])
    sys.exit(result.returncode)
