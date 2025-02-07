import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/src/components/sprite_component.dart';
import 'package:vector_math/vector_math_64.dart';

class EndCacheService extends SpriteCache {
  @override
  Future<SpriteComponent> getSpriteComponent({required String path, required Vector2 imgSize}) {
    // TODO: implement getSpriteComponent
    throw UnimplementedError();
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) {
    // TODO: implement preloadSprites
    throw UnimplementedError();
  }
}