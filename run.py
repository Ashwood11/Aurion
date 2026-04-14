# aurion/run.py
import sys
import os

# Add project root to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Now you can import anything
from core.database.db import init_db

if __name__ == "__main__":
    init_db()
    print("✅ Aurion database initialized!")