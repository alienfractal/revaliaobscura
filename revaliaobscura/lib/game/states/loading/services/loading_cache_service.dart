import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';

class LoadingCacheService extends SpriteAnimatorCache {
  late StaticSprite gameBackground;

  @override
  SpriteAnimation getAnimation(int modelValue) {
    throw UnimplementedError();
  }

  @override
  SpriteComponent getSpriteComponent(
      {required Sprite sprite, required Vector2 imgSize}) {
    throw UnimplementedError();
  }

  @override
  String getSpritePath(int type) {
    throw UnimplementedError();
  }

  @override
  Future<void> preloadAnimations(RevaliaObs gameRef) async {}

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    gameBackground = StaticSprite(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.gameBackground32x32.path),
        gameRef.camDimension);
  }
}
