from pathlib import Path
import hashlib
import json

here = Path(__file__).resolve().parent
root = here.parent.parent
stage = here / '.forest-mushrooms-work'
paths = ['resources/scenarios/forest.json', 'lib/game/states/level_game/view/gameboard_view.dart', 'resources/dialogues/revalia_dialogues.json', *[f'resources/translations/{locale}.json' for locale in ['en', 'es', 'ee']], 'test/quest_views_test.dart']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
before = {p: sha(root / p) for p in paths}
for p in paths:
    assert sha(stage / p) == before[p], 'Staging is stale: ' + p
def edit(path, old, new):
    p = stage / path
    text = p.read_text(encoding='utf-8')
    assert text.count(old) == 1, path
    p.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')

scene = 'resources/scenarios/forest.json'
edit(scene, '"size": [\n        32,\n        51\n      ]', '"size": [\n        16,\n        25.5\n      ]')
board = 'lib/game/states/level_game/view/gameboard_view.dart'
edit(board, '    isGameFinished = true;\n    playerEntity.disableActions();\n    activeActor.requestAttack(', "    final deathMessageKey = activeActor.interactionId == 'knife_mushroom'\n        ? 'knife_mushroom_killed'\n        : 'player_killed';\n    isGameFinished = true;\n    playerEntity.disableActions();\n    activeActor.requestAttack(")
edit(board, 'onComplete: _finishPlayerDeath,', 'onComplete: () => _finishPlayerDeath(deathMessageKey),')
edit(board, 'void _finishPlayerDeath() {', 'void _finishPlayerDeath(String messageKey) {')
edit(board, "DialogueManager.message('player_killed'),", 'DialogueManager.message(messageKey),')
edit('resources/dialogues/revalia_dialogues.json', '"player_killed": {},', '"player_killed": {},\n    "knife_mushroom_killed": {},')
messages = {'en': 'The mushroom stabs you. That was the wrong answer.', 'es': 'El hongo te apuñala. Esa fue la respuesta equivocada.', 'ee': 'Seen pussitab sind. See oli vale vastus.'}
for locale, message in messages.items():
    edit(f'resources/translations/{locale}.json', '    "player_killed": {', '    "knife_mushroom_killed": {\n      "text": ' + json.dumps(message, ensure_ascii=False) + '\n    },\n    "player_killed": {')
test = 'test/quest_views_test.dart'
edit(test, '    expect(knife.animationHandler.idleAnimation.frames.length, 9);', '    expect(knife.size, Vector2(16, 25.5));\n    expect(knife.animationHandler.idleAnimation.frames.length, 9);')
edit(test, "    await _capture(tester, 'knife-mushroom-death');", "    expect(\n        game.gboard.df!.children.whereType<TextBoxComponent>().map((c) => c.text),\n        contains('The mushroom stabs you. That was the wrong answer.'));\n    await _capture(tester, 'knife-mushroom-death');")
plan = {'root': str(root), 'changes': [{'path': p, 'before': before[p], 'after': sha(stage / p)} for p in paths]}
(here / 'mushroom-fixes-changes.json').write_text(json.dumps(plan, indent=2), encoding='utf-8')
print('Prepared seven files with stale-edit checks.')
