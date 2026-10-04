import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class UiSpriteCacheService extends SpriteAnimatorCache {
  late StaticSprite startButton;
  late CachedSpriteSheet soundFxVolume;
  late CachedSpriteSheet musicFxVolume;
  late CachedAnimatedButtonSprite crtShaderButton;

  @override
  SpriteAnimation getAnimation(int modelValue) {
    throw UnsupportedError('UiSpriteCacheService uses named assets.');
  }

  @override
  String getSpritePath(int type) {
    throw UnsupportedError('UiSpriteCacheService uses named assets.');
  }

  @override
  Future<void> preloadAnimations(RevaliaObs gameRef) async {
    final frameSize = Vector2(32, 32);
    final buttonSize = Vector2(32, 32);
    final path = Assets.resources.images.crton32x328.path;

    crtShaderButton = CachedAnimatedButtonSprite(
      idleSprite: await gameRef.loadSprite(path, srcSize: frameSize),
      tapAnimation: await gameRef.loadSpriteAnimation(
        path,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.12,
          textureSize: frameSize,
          loop: false,
        ),
      ),
      buttonSize: buttonSize,
      frameSize: frameSize,
    );
  }

  @override
  SpriteComponent getSpriteComponent(
      {required Sprite sprite, required Vector2 imgSize}) {
    return SpriteComponent(sprite: sprite, size: imgSize.clone());
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    final volumeButtonSize = Vector2(17, 17);

    startButton = StaticSprite(
      await SpriteAnimatorCache.loadSprite(
        path: Assets.resources.images.buttonstart.path,
      ),
      Vector2(100, 22),
    );
    soundFxVolume = CachedSpriteSheet(
      spriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await gameRef.images.load(
          Assets.resources.images.soundfxVolume.path,
        ),
        columns: 4,
        rows: 1,
      ),
      imgSize: volumeButtonSize,
      columns: 4,
      rows: 1,
    );
    musicFxVolume = CachedSpriteSheet(
      spriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await gameRef.images.load(
          Assets.resources.images.musicfxVolume.path,
        ),
        columns: 4,
        rows: 1,
      ),
      imgSize: volumeButtonSize,
      columns: 4,
      rows: 1,
    );
  }
}
