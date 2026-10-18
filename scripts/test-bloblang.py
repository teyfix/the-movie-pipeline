#!/usr/bin/env python3
"""Run blobl fixtures against the actual mapping sources without copying them."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
state = ROOT / ".state/bloblang/tests"
state.mkdir(parents=True, exist_ok=True)
status = 0
for fixture in sorted((ROOT / "tests/bloblang").glob("*.json")):
  suite = json.loads(fixture.read_text())
  suite["source"] = (ROOT / suite.pop("mapping")).read_text()
  with tempfile.TemporaryDirectory(dir=state) as temporary:
    path = Path(temporary) / fixture.name
    path.write_text(json.dumps(suite))
    print(fixture.name, flush=True)
    result = subprocess.run(["blobl", "test", str(path)], cwd=ROOT)
    status = max(status, result.returncode)
sys.exit(status)
