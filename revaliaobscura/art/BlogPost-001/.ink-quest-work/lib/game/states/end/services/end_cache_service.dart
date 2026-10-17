import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';

class EndCacheService extends SpriteAnimatorCache {
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
  Future<void> preloadAnimations(RevaliaObs gameRef) {
    throw UnimplementedError();
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) {
    throw UnimplementedError();
  }
}
