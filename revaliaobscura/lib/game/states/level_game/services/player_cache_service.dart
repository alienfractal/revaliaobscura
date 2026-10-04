import 'package:revalia/game/states/level_game/model/player_model.dart';
import 'package:revalia/revalia_obs.dart';

import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:flame/components.dart';

class PlayerCacheService extends SpriteAnimatorCache {
  late SpriteAnimation walkingPlayer;

  late SpriteAnimation idlePlayer;

  late SpriteAnimation talkPlayer;

  late SpriteAnimation laughPlayer;

  late SpriteAnimation knockedPlayer;

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

    laughPlayer = await gameRef.loadSpriteAnimation(
      Assets.resources.images.rebaneLaughts50x843.path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.15,
        textureSize: Vector2(50, 84),
        loop: true,
      ),
    );

    knockedPlayer = await gameRef.loadSpriteAnimation(
      Assets.resources.images.rebaneKnocked84x846.path,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.15,
        textureSize: Vector2(84, 84),
        loop: false,
      ),
    );

    print("All player animations preloaded successfully.");
  }

  @override
  String getSpritePath(int type) {
    throw UnsupportedError('PlayerCacheService uses named animations.');
  }

  @override
  SpriteAnimation getAnimation(int modelValue) {
    print("getAnimation modelValue $modelValue");
    switch (modelValue) {
      case PlayerModel.IDLE:
        return idlePlayer;
      case PlayerModel.WALKING:
        return walkingPlayer;
      case PlayerModel.TALK:
        return talkPlayer;
      case PlayerModel.LAUGH:
        return laughPlayer;
      case PlayerModel.DIE:
        return knockedPlayer;

      default:
        throw Exception('Unknown player animation: $modelValue');
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
