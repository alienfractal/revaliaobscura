from pathlib import Path
import json
import hashlib
import difflib

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
STAGE = HERE / '.ink-quest-work'
baseline = json.loads((STAGE / '.baseline.json').read_text())
changes = []
patch = []
for folder in ['lib', 'resources', 'test']:
    for path in sorted((STAGE / folder).rglob('*')):
        if not path.is_file(): continue
        rel = path.relative_to(STAGE).as_posix()
        checksum = hashlib.sha256(path.read_bytes()).hexdigest()
        if baseline.get(rel) == checksum: continue
        changes.append({'path': rel, 'before': baseline.get(rel), 'after': checksum})
        if path.suffix in ['.dart','.json','.md']:
            original = (REPO / rel).read_text(encoding='utf-8').splitlines(True) if (REPO/rel).exists() else []
            patch.extend(difflib.unified_diff(original, path.read_text(encoding='utf-8').splitlines(True),
                fromfile='a/'+rel, tofile='b/'+rel))
(HERE/'ink-quest-changes.json').write_text(json.dumps(changes,indent=2)+'\n')
(HERE/'ink-quest-demo.patch').write_text(''.join(patch),encoding='utf-8')
print('\n'.join(c['path'] for c in changes))
print(f'{len(changes)} files prepared; original files unchanged.')
