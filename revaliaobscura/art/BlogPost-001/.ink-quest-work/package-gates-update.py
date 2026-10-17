from pathlib import Path
import json
import hashlib

STAGE=Path(__file__).resolve().parent
baseline=json.loads((STAGE/'gates-baseline.json').read_text())
changes=[]
for folder in ['lib','resources','test']:
    for p in sorted((STAGE/folder).rglob('*')):
        if not p.is_file(): continue
        rel=p.relative_to(STAGE).as_posix()
        digest=hashlib.sha256(p.read_bytes()).hexdigest()
        if digest==baseline.get(rel): continue
        changes.append({'path':rel,'before':baseline.get(rel),'after':digest})
(STAGE/'gates-changes.json').write_text(json.dumps(changes,indent=2))
print('\n'.join(c['path'] for c in changes))
print('Prepared',len(changes),'files. Existing project artwork is unchanged.')
