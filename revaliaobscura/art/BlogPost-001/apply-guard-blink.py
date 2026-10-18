from pathlib import Path
import hashlib
import json
import shutil

here = Path(__file__).resolve().parent
root = here.parent.parent.resolve()
stage = (here / '.forest-mushrooms-work').resolve()
plan = json.loads((here / 'guard-blink-changes.json').read_text(encoding='utf-8'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert Path(plan['root']).resolve() == root
for entry in plan['changes']:
    target = (root / entry['path']).resolve()
    source = (stage / entry['path']).resolve()
    assert target.is_relative_to(root) and source.is_relative_to(stage)
    assert sha(target) == entry['before'], 'Game file changed: ' + entry['path']
    assert sha(source) == entry['after'], 'Stage changed: ' + entry['path']
for entry in plan['changes']:
    relative = entry['path']
    backup = here / 'guard-blink-backup' / relative
    assert not backup.exists()
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(root / relative, backup)
    shutil.copy2(stage / relative, root / relative)
    assert sha(root / relative) == entry['after']
print('Applied tested guard blink sequence. Backups retained.')
