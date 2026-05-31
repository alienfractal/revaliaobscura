import 'package:revalia/game/states/game/model/player_model.dart';
import 'package:revalia/revalia_obs.dart';

import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:flame/components.dart';

class PlayerCacheService extends SpriteAnimatorCache {
  // Individual animations for card types

  late SpriteAnimation walkingPlayer;

  late SpriteAnimation idlePlayer;

  late SpriteSpec oldTownCenter;

  late SpriteAnimation talkPlayer;

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
        textureSize: Vector2(50, 84),
        loop: true,
      ),
    );

    talkPlayer = await gameRef.loadSpriteAnimation(
      Assets.resources.images.rebane50x84Talk6.path,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.12,
        textureSize: Vector2(50, 84),
        loop: true,
      ),
    );

    oldTownCenter = SpriteSpec(
        await SpriteAnimatorCache.loadSprite(
            path: Assets.resources.images.revalTowncenter320x200.path),
        Vector2(320, 200));

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
  SpriteComponent getSpriteComponent(
      {required Sprite sprite, required Vector2 imgSize}) {
    return SpriteComponent(sprite: sprite, size: imgSize);
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async {
    // gameBackground = await getSpriteComponent(
    // path: Assets.resources.images.gameBackground32x32.path,
    //  imgSize: gameRef.camDimension);
  }
}
