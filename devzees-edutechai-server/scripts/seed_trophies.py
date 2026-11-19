"""
EduTechAI — Dynamic Trophy Unlock & Progression Seeder (Convenience Wrapper)

For detailed documentation, see scripts/seeder/06_seed_trophies.py.
"""

from __future__ import annotations
import importlib
import os
import sys

SERVER_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if SERVER_ROOT not in sys.path:
    sys.path.insert(0, SERVER_ROOT)

seeder = importlib.import_module("scripts.seeder.06_seed_trophies")

if __name__ == "__main__":
    seeder.main()
