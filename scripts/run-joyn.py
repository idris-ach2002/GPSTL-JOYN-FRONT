#!/usr/bin/env python3
"""Launch Flutter with a dotenv file without evaluating shell expressions."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
values = {}
path = root / '.env'
if path.exists():
    for number, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise SystemExit(f'.env:{number}: KEY=value attendu')
        key, value = line.split('=', 1)
        key, value = key.strip(), value.strip()
        if key not in {'JOYN_DATA_MODE', 'JOYN_API_BASE_URL', 'JOYN_API_TIMEOUT_MS'}:
            raise SystemExit(f'.env:{number}: variable inconnue {key}')
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
            value = value[1:-1]
        values[key] = value
args = sys.argv[1:] or ['run', '-d', 'chrome', '-t', 'lib/main.dart']
with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
    json.dump(values, f)
    config_path = f.name
try:
    raise SystemExit(subprocess.call(['flutter', *args, f'--dart-define-from-file={config_path}'], cwd=root))
finally:
    os.unlink(config_path)
