from pathlib import Path
import hashlib
import json
import shutil

here = Path(__file__).resolve().parent
root = here.parent.parent.resolve()
stage = (here / '.forest-mushrooms-work').resolve()
plan = json.loads((here / 'mushroom-fixes-changes.json').read_text(encoding='utf-8'))
assert Path(plan['root']).resolve() == root
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
for entry in plan['changes']:
    target = (root / entry['path']).resolve()
    source = (stage / entry['path']).resolve()
    assert target.is_relative_to(root) and source.is_relative_to(stage)
    assert sha(target) == entry['before'], 'Game file changed: ' + entry['path']
    assert sha(source) == entry['after'], 'Stage changed: ' + entry['path']
river = root / 'resources/scenarios/river_crossing.json'
river_before = sha(river)
for entry in plan['changes']:
    relative = entry['path']
    backup = here / 'mushroom-fixes-backup' / relative
    backup.parent.mkdir(parents=True, exist_ok=True)
    assert not backup.exists(), 'Backup already exists: ' + relative
    shutil.copy2(root / relative, backup)
    shutil.copy2(stage / relative, root / relative)
    assert sha(root / relative) == entry['after']
assert sha(river) == river_before
shutil.copy2(stage / 'build/quest-previews/forest.png', here / 'forest-mushrooms-preview.png')
shutil.copy2(stage / 'build/quest-previews/knife-mushroom-death.png', here / 'mushroom-death-preview.png')
print('Applied seven tested files; backups retained. River crossing unchanged.')
