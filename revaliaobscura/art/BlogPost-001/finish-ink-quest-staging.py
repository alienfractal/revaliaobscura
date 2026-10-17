from pathlib import Path
import json
import hashlib

r = Path(__file__).resolve().parents[2]
s = r / 'art/BlogPost-001/.ink-quest-work'
files = [p for d in ['lib','resources','test'] for p in (r/d).rglob('*') if p.is_file()]
(s/'.baseline.json').write_text(json.dumps({p.relative_to(r).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in files}))
print('Baseline:', len(files))
p = s/'resources/scenarios/river_crossing.json'
d = json.loads(p.read_text())
d['walking_area']['vertices'] = [[0,150],[320,150],[320,178],[0,178]]
p.write_text(json.dumps(d,indent=2)+'\n')
p = s/'test/adventure_state_test.dart'
t = p.read_text().replace("state.collectPickup('ink_bottle_pickup')", "state.collectPickup('empty_bottle_pickup')")
t = t.replace("expect(state.quantity('ink_bottle'), 1);\n    expect(state.status('navigator_ink'), QuestStatus.ready);", "expect(state.quantity('empty_bottle'), 1);\n    state.removeItem('empty_bottle');\n    state.addItem('ink_bottle');\n    expect(state.status('navigator_ink'), QuestStatus.ready);")
p.write_text(t)
