from pathlib import Path
import hashlib
import json
import shutil

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
STAGE = HERE / '.ink-quest-work'
paths = [
    'lib/game/states/level_game/services/entity_sprite_cache_service.dart',
    'lib/game/states/level_game/view/female_clothes_trader_npc_entity.dart',
]
manifest = []
for rel in paths:
    original = (REPO / rel).read_bytes()
    text = original.decode('utf-8').replace('\r\n', '\n')
    if rel.endswith('entity_sprite_cache_service.dart'):
        text = text.replace('late AnimatedSprite npcFemaleClothesTraderIdle;',
            'late AnimatedSprite npcFemaleClothesTraderIdle;\n  late AnimatedSprite npcFemaleClothesTraderTalk;')
        start = text.index('    npcFemaleClothesTraderIdle = AnimatedSprite(')
        end = text.index('    scoreIcon = AnimatedSprite(', start)
        text = text[:start] + '''    npcFemaleClothesTraderIdle = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.clothesTraderLadyIdle50x857.path,
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.5,
          textureSize: Vector2(31, 84),
          loop: true,
        ),
      ),
      Vector2(31, 84),
    );

    npcFemaleClothesTraderTalk = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.clothesTraderLadyTalking50x857.path,
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.12,
          textureSize: Vector2(31, 84),
          loop: true,
        ),
      ),
      Vector2(31, 84),
    );

''' + text[end:]
    else:
        old = 'game.entitySpriteCache.npcFemaleClothesTraderIdle.animation,'
        assert old in text
        text = text.replace(old, old + '\n      talkAnimation:\n          game.entitySpriteCache.npcFemaleClothesTraderTalk.animation,')
        text = text.replace('    animationHandler.init(',
            '    final visualSize = game.entitySpriteCache.npcFemaleClothesTraderIdle.imgSize * (size.y / 85);\n    animationHandler.init(')
        text = text.replace('      size: size,\n      parent: this,', '      size: visualSize,\n      parent: this,')
        text = text.replace('      parent: this,\n    );',
            '      parent: this,\n    );\n    animationHandler.spriteAnimationComponent.position = Vector2(size.x / 2, size.y);')
    (STAGE / rel).write_text(text, encoding='utf-8')
    manifest.append({'path':rel, 'before':hashlib.sha256(original).hexdigest(),
        'after':hashlib.sha256((STAGE/rel).read_bytes()).hexdigest()})
for filename in ['clothes-trader-lady-idle-50x85-7.png', 'clothes-trader-lady-talking-50x85-7.png']:
    shutil.copy2(REPO/'resources/images'/filename, STAGE/'resources/images'/filename)
(HERE/'lady-animation-changes.json').write_text(json.dumps(manifest,indent=2))
print('Prepared idle and talking animation hookup in two source files.')
