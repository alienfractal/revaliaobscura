from pathlib import Path
import hashlib
import json
import shutil

here = Path(__file__).resolve().parent
root = here.parent.parent
stage = here / '.forest-mushrooms-work'
paths = ['resources/dialogues/revalia_dialogues.json', 'resources/scenarios/city_gates.json', 'lib/game/states/level_game/view/inventory_popup.dart', 'test/quest_views_test.dart']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
before = {p: sha(root / p) for p in paths}
for p in paths: shutil.copy2(root / p, stage / p)
def edit(path, old, new):
    p = stage / path
    text = p.read_text(encoding='utf-8')
    assert text.count(old) == 1, path
    p.write_text(text.replace(old, new), encoding='utf-8', newline='\r\n')
for item, asset in [('empty_bottle', 'empty-bottle-16x16-1.png'), ('ink_bottle', 'ink-bottle-16x16-1.png')]:
    edit(paths[0], f'"{item}": {{\n      "usable": true', f'"{item}": {{\n      "icon": "resources/images/{asset}",\n      "usable": true')
    shutil.copy2(root / 'resources/images' / asset, stage / 'resources/images' / asset)
edit(paths[1], '"asset_id": "placeholder:empty_bottle_pickup"', '"asset_id": "resources/images/empty-bottle-16x16-1.png"')
edit(paths[1], '"size": [\n        25,\n        16\n      ]', '"size": [\n        16,\n        16\n      ]')
edit(paths[2], '''        _icons[id]!.render(canvas,
            position: Vector2(iconRect.left, iconRect.top),
            size: Vector2(iconRect.width, iconRect.height));''', '''        final icon = _icons[id]!;
        final fit = math.min(1.0,
            iconRect.width / math.max(icon.srcSize.x, icon.srcSize.y));
        final iconSize = icon.srcSize * fit;
        icon.render(canvas,
            position: Vector2(
                (iconRect.center.dx - iconSize.x / 2).roundToDouble(),
                (iconRect.center.dy - iconSize.y / 2).roundToDouble()),
            size: iconSize);''')
edit(paths[3], "    expect(state.hasItem('empty_bottle'), isTrue);\n    await tester.tapAt(const Offset(320, 160));", "    expect(state.hasItem('empty_bottle'), isTrue);\n    await tester.tapAt(const Offset(320, 160));\n    game.gboard.toggleInventory();\n    await _settle(tester, game);\n    await _capture(tester, 'inventory-empty-bottle');\n    game.gboard.closeInventory();")
edit(paths[3], "    await _capture(tester, 'forest-ink-collected');\n    await tester.tapAt(const Offset(320, 160));", "    await _capture(tester, 'forest-ink-collected');\n    await tester.tapAt(const Offset(320, 160));\n    game.gboard.toggleInventory();\n    await _settle(tester, game);\n    await _capture(tester, 'inventory-ink-bottle');\n    game.gboard.closeInventory();")
plan = {'root': str(root), 'changes': [{'path': p, 'before': before[p], 'after': sha(stage / p)} for p in paths]}
(here / 'bottle-art-changes.json').write_text(json.dumps(plan, indent=2), encoding='utf-8')
print('Prepared bottle inventory icons and scene pickup at native 16 x 16 size.')
