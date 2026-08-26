import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';

class MenuCacheSerivce extends SpriteAnimatorCache {
  late StaticSprite gameBackground;
  late StaticSprite gameTitle;
  late StaticSprite gameSubTitle;
  late StaticSprite companyTitle;
  late StaticSprite gameConverMenu;

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    gameConverMenu = StaticSprite(
        await SpriteAnimatorCache.loadSprite(path: Assets.resources.images.gamecoverMenu.path),
        Vector2(320, 180));


    companyTitle = StaticSprite(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.gamelogo140x32.path),
        Vector2(140, 32));
    gameBackground = StaticSprite(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.gameBackground32x32.path),
        gameRef.camDimension);
    gameTitle = StaticSprite(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.gameTitlePng.path),
        Vector2(104, 56));
    gameSubTitle = StaticSprite(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.gamesubTitlePng.path),
        Vector2(140, 32));
  }

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
}
