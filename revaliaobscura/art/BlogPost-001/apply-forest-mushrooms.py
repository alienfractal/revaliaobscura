"""Apply only reviewed staged files, with stale-edit checks and local backups."""
from pathlib import Path
import hashlib
import json
import shutil

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent.resolve()
STAGE=HERE/'.forest-mushrooms-work'
BACKUP=HERE/'forest-mushrooms-backup'
plan=json.loads((HERE/'forest-mushrooms-changes.json').read_text(encoding='utf-8'))
assert Path(plan['root']).resolve()==ROOT
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

# Validate all paths and hashes before changing any game file.
for entry in plan['changes']:
    target=(ROOT/entry['path']).resolve()
    source=(STAGE/entry['path']).resolve()
    assert target.is_relative_to(ROOT) and source.is_relative_to(STAGE.resolve())
    assert sha(target)==entry['before'], 'Game file changed since staging: '+entry['path']
    assert sha(source)==entry['after'], 'Staged file changed: '+entry['path']
river=ROOT/'resources/scenarios/river_crossing.json'
river_hash=sha(river)
for entry in plan['changes']:
    path=entry['path']
    backup=BACKUP/path
    backup.parent.mkdir(parents=True,exist_ok=True)
    if not backup.exists(): shutil.copy2(ROOT/path,backup)
    shutil.copy2(STAGE/path,ROOT/path)
    assert sha(ROOT/path)==entry['after']
assert sha(river)==river_hash, 'River crossing was unexpectedly changed'
print(f"Applied {len(plan['changes'])} tested files. Backups retained. River crossing unchanged.")
