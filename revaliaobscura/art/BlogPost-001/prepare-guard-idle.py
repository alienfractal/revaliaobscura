from pathlib import Path
import hashlib
import json
import shutil

here = Path(__file__).resolve().parent
root = here.parent.parent
stage = here / '.forest-mushrooms-work'
paths = ['resources/scenarios/town_square.json', 'test/quest_views_test.dart']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
before = {p: sha(root / p) for p in paths}
for p in paths:
    shutil.copy2(root / p, stage / p)
scene = stage / paths[0]
text = scene.read_text(encoding='utf-8')
old = '"type": "npc",\n      "asset_id": "old_sailor",\n      "interaction_id": "city_guard",'
new = '"type": "quest_prop",\n      "asset_id": "resources/images/guard-idle-50x85-1.png",\n      "interaction_id": "city_guard",'
assert text.count(old) == 1
text = text.replace(old, new)
old = '"dialogue_actor_id": "city_guard"'
new = '"dialogue_actor_id": "city_guard",\n      "animation": {\n        "frames": 2,\n        "width": 50,\n        "height": 85,\n        "step_time": 0.4\n      }'
assert text.count(old) == 1
scene.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')
test = stage / paths[1]
text = test.read_text(encoding='utf-8')
old = '    game.gboard.callRenderDialogue(guard);'
new = '''    expect(guard.animationHandler.idleAnimation.frames.length, 2);
    expect(guard.animationHandler.idleAnimation.loop, isTrue);
    expect(guard.animationHandler.idleAnimation.frames.first.sprite.srcSize,
        Vector2(50, 85));
    game.gboard.callRenderDialogue(guard);'''
assert text.count(old) == 1
test.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')
asset = 'resources/images/guard-idle-50x85-1.png'
shutil.copy2(root / asset, stage / asset)
plan = {'root': str(root), 'asset': asset, 'asset_hash': sha(root / asset), 'changes': [{'path': p, 'before': before[p], 'after': sha(stage / p)} for p in paths]}
(here / 'guard-idle-changes.json').write_text(json.dumps(plan, indent=2), encoding='utf-8')
print('Prepared guard idle replacement: two 50 x 85 frames, 0.4 seconds each.')
