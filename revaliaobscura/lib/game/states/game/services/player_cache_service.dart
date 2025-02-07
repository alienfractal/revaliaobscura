import 'package:coolorburn/game/states/game/model/player_model.dart';
import 'package:coolorburn/revalia_obs.dart';
 
import 'package:coolorburn/utils/image/sprite_animator_cache_service.dart';
import 'package:coolorburn/gen/assets.gen.dart';
import 'package:flame/sprite.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/components/sprite_component.dart';

class PlayerCacheService extends SpriteAnimatorCache implements SpriteCache {
  // Individual animations for card types

  late SpriteAnimation walkingPlayer;

  late SpriteAnimation idlePlayer;

  late SpriteComponent oldTownCenter;

  @override
  Future<void> preloadAnimations(RevaliaObs gameRef) async {

    walkingPlayer = await gameRef.loadSpriteAnimation(
      Assets.resources.images.rebane50x849.path,
      SpriteAnimationData.sequenced(
        amount: 9,
        stepTime: 0.1,
        textureSize: Vector2(50, 84),
        loop: true,
      ),
    );

    idlePlayer = await gameRef.loadSpriteAnimation(
      Assets.resources.images.rebane50x84Idle16.path,
      SpriteAnimationData.sequenced(
        amount: 15,
        stepTime: 0.3,
        textureSize: Vector2(50,84),
        loop: true,
      ),);

     oldTownCenter = await getSpriteComponent(
        path: Assets.resources.images.revalTowncenter320x200.path,
        imgSize: Vector2(320 ,200 ) );

    print("All player animations preloaded successfully.");
  }

  @override
  String getSpritePath(int type) {
    switch (type) {
      case PlayerModel.IDLE:
        return Assets.resources.images.blacksquare48x48.path;
      case PlayerModel.WALKING:
        return Assets.resources.images.celldarkDirtRelicSheet.path;
      default:
        throw Exception('Unknown CardType: $type');
    }
  }

  @override
  SpriteAnimation getAnimation(int modelValue) {
    print("getAnimation modelValue $modelValue");
    switch (modelValue) {
      case PlayerModel.IDLE:
        return walkingPlayer;
      case PlayerModel.WALKING:
        return walkingPlayer;

      default:
        throw Exception('Unknown CardType: $modelValue');
    }
  }

  @override
  Future<SpriteComponent> getSpriteComponent(
      {required String path, required Vector2 imgSize}) async {
    Sprite sprite = await SpriteAnimatorCache.loadSprite(path);
    return SpriteComponent(sprite: sprite, size: imgSize);
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    // gameBackground = await getSpriteComponent(
    // path: Assets.resources.images.gameBackground32x32.path,
    //  imgSize: gameRef.camDimension);
  }
}
