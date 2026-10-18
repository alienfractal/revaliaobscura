from pathlib import Path
import hashlib
import json
import shutil

here = Path(__file__).resolve().parent
root = here.parent.parent
stage = here / '.forest-mushrooms-work'
paths = ['resources/scenarios/town_square.json', 'test/quest_views_test.dart']
sequence = '1111111111111111111111112222222221111111111122221211212121222222222222111111'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
before = {p: sha(root / p) for p in paths}
for p in paths:
    shutil.copy2(root / p, stage / p)
scene = stage / paths[0]
text = scene.read_text(encoding='utf-8')
old = '"height": 85,\n        "step_time": 0.4'
new = '"height": 85,\n        "step_time": 0.1,\n        "sequence": [' + ', '.join(sequence) + ']'
assert text.count(old) == 1
scene.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')
test = stage / paths[1]
text = test.read_text(encoding='utf-8')
old = '    expect(guard.animationHandler.idleAnimation.frames.length, 2);'
new = f'''    const guardSequence = '{sequence}';
    expect(
        guard.animationHandler.idleAnimation.frames
            .map((frame) => (frame.sprite.srcPosition.x / 50).round() + 1)
            .join(),
        guardSequence);
    expect(guard.animationHandler.idleAnimation.frames
        .every((frame) => frame.stepTime == 0.1), isTrue);'''
assert text.count(old) == 1
test.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')
plan = {'root': str(root), 'changes': [{'path': p, 'before': before[p], 'after': sha(stage / p)} for p in paths]}
(here / 'guard-blink-changes.json').write_text(json.dumps(plan, indent=2), encoding='utf-8')
print(f'Prepared exact requested sequence: {len(sequence)} steps, {len(sequence) * 0.1:.1f} seconds per loop.')
