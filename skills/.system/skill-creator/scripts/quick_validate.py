#!/usr/bin/env python3
"""Compatibility wrapper for the repository skill validator."""

import runpy
import sys
from pathlib import Path


def main():
    root_dir = Path(__file__).resolve().parents[4]
    validator = root_dir / "scripts" / "skill-quick-validate.py"
    if not validator.exists():
        print(f"Missing validator script: {validator.relative_to(root_dir)}", file=sys.stderr)
        return 1

    sys.argv[0] = str(validator)
    runpy.run_path(str(validator), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
