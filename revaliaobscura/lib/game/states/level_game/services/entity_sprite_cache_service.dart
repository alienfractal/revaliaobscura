import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:flame/components.dart';

class EntitySpriteCacheService extends SpriteAnimatorCache {
  late StaticSprite gameBackground;
  late StaticSprite townCenterBackground;
  late AnimatedSprite sandClockPowerUp;
  late AnimatedSprite potionEnergyPowerUp;
  late AnimatedSprite coinPowerUp;
  late AnimatedSprite scoreIcon;
  late AnimatedSprite walkingArea;

  late AnimatedSprite townCenterMarketAnimation;

  late StaticSprite walkButtonSprite;
  late StaticSprite lookAtButtonSprite;
  late StaticSprite talkToButtonSprite;
  late StaticSprite touchButtonSprite;

  late AnimatedSprite npcOldSailorIdle;
  late AnimatedSprite npcOldSailorTalk;
  late AnimatedSprite npcOldSailorAttack;
  late AnimatedSprite glowingGem;

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
    glowingGem = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.gem1GlowingSheet32x324.path,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(32, 32),
          loop: true,
        ),
      ),
      Vector2(32, 32),
    );

    townCenterMarketAnimation = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.revalTowncenterMarketAnimation320x200.path,
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.35,
          textureSize: Vector2(320, 200),
          loop: true,
        ),
      ),
      Vector2(320, 200),
    );

    walkingArea = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.walkingArea.path,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      ),
      Vector2(256, 32),
    );

    npcOldSailorIdle = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.mecharchtSailorSheet750x85.path,
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.5,
          textureSize: Vector2(50, 85),
          loop: true,
        ),
      ),
      Vector2(50, 85),
    );

    npcOldSailorTalk = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.mecharchtSailorTalk50x859Sheet.path,
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.12,
          textureSize: Vector2(50, 85),
          loop: true,
        ),
      ),
      Vector2(50, 85),
    );

    npcOldSailorAttack = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.mecharchtSailorAttack50x858.path,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.12,
          textureSize: Vector2(50, 85),
          loop: false,
        ),
      ),
      Vector2(50, 85),
    );

    scoreIcon = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.scoreiconSheet.path,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.55,
          textureSize: Vector2(32, 32),
          loop: true,
        ),
      ),
      Vector2(32, 32),
    );

    sandClockPowerUp = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.sandclockSheet.path,
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: true,
        ),
      ),
      Vector2(32, 32),
    );

    potionEnergyPowerUp = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.potionSheet.path,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: true,
        ),
      ),
      Vector2(32, 32),
    );

    coinPowerUp = AnimatedSprite(
      await gameRef.loadSpriteAnimation(
        Assets.resources.images.scoreiconSheet.path,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: true,
        ),
      ),
      Vector2(32, 32),
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
    gameBackground = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.gameBackground32x32.path,
      ),
      gameRef.camDimension,
    );
    townCenterBackground = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.revalTowncenter320x200Png.path,
      ),
      gameRef.camDimension,
    );
    walkButtonSprite = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.actionIconWalk24x24.path,
      ),
      Vector2(24, 24),
    );
    lookAtButtonSprite = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.actionIconLook24x24.path,
      ),
      Vector2(24, 24),
    );
    talkToButtonSprite = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.actionIconTalk24x24.path,
      ),
      Vector2(24, 24),
    );
    touchButtonSprite = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.actionIconTouch24x24.path,
      ),
      Vector2(24, 24),
    );
  }
}
