import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:flame/components.dart';

class EntitySpriteCacheService extends SpriteAnimatorCache {
  late SpriteSpec gameBackground;
  late SpriteAnimation sandClockPowerUp;
  late SpriteAnimation potionEnergyPowerUp;
  late SpriteAnimation coinPowerUp;
  late SpriteAnimation scoreIcon;
  late SpriteAnimation walkingArea;

  late SpriteAnimation gameTownAnimationBackground;

  late SpriteSpec walkButtonSprite;
  late SpriteSpec lookAtButtonSprite;
  late SpriteSpec talkToButtonSprite;
  late SpriteSpec touchButtonSprite;

  late SpriteAnimation npcOldSailorIdle;
  late SpriteAnimation npcOldSailorTalk;

  @override
  String getSpritePath(int type) {
    throw UnsupportedError('EntitySpriteCacheService uses named assets.');
  }

  @override
  SpriteAnimation getAnimation(int modelValue) {
    throw UnsupportedError('EntitySpriteCacheService uses named animations.');
  }

  @override
  Future<void> preloadAnimations(RevaliaObs gameRef) async {
    gameTownAnimationBackground = await gameRef.loadSpriteAnimation(
      Assets.resources.images.revalTowncenterMarketAnimation320x200.path,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.35,
        textureSize: Vector2(320, 200),
        loop: true,
      ),
    );

    walkingArea = await gameRef.loadSpriteAnimation(
      Assets.resources.images.walkingArea.path,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    npcOldSailorIdle = await gameRef.loadSpriteAnimation(
      Assets.resources.images.mecharchtSailorSheet750x85.path,
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.5,
        textureSize: Vector2(50, 85),
        loop: true,
      ),
    );

    npcOldSailorTalk = await gameRef.loadSpriteAnimation(
      Assets.resources.images.mecharchtSailorTalk50x859Sheet.path,
      SpriteAnimationData.sequenced(
        amount: 9,
        stepTime: 0.12,
        textureSize: Vector2(50, 85),
        loop: true,
      ),
    );

    scoreIcon = await gameRef.loadSpriteAnimation(
      Assets.resources.images.scoreiconSheet.path,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.55,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    sandClockPowerUp = await gameRef.loadSpriteAnimation(
      Assets.resources.images.sandclockSheet.path,
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    potionEnergyPowerUp = await gameRef.loadSpriteAnimation(
      Assets.resources.images.potionSheet.path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    coinPowerUp = await gameRef.loadSpriteAnimation(
      Assets.resources.images.scoreiconSheet.path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    print("Level entity sprites preloaded successfully.");
  }

  @override
  SpriteComponent getSpriteComponent(
      {required Sprite sprite, required Vector2 imgSize}) {
    return SpriteComponent(sprite: sprite, size: imgSize);
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    gameBackground = await _loadSpriteSpec(
        Assets.resources.images.gameBackground32x32.path, gameRef.camDimension);
    walkButtonSprite = await _loadSpriteSpec(
        Assets.resources.images.actionIconWalk24x24.path, Vector2(24, 24));
    lookAtButtonSprite = await _loadSpriteSpec(
        Assets.resources.images.actionIconLook24x24.path, Vector2(24, 24));
    talkToButtonSprite = await _loadSpriteSpec(
        Assets.resources.images.actionIconTalk24x24.path, Vector2(24, 24));
    touchButtonSprite = await _loadSpriteSpec(
        Assets.resources.images.actionIconTouch24x24.path, Vector2(24, 24));
  }

  Future<SpriteSpec> _loadSpriteSpec(String path, Vector2 imgSize) async {
    return SpriteSpec(
        await SpriteAnimatorCache.loadSprite(path: path), imgSize);
  }
}
