import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/game/states/game/model/actor_model.dart';
import 'package:coolorburn/utils/sprite_animator_cache_service.dart';
import 'package:coolorburn/gen/assets.gen.dart';
import 'package:flame/sprite.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/components/sprite_component.dart';

class CardCacheService extends SpriteAnimatorCache implements SpriteCache {
  // Individual animations for card types
  late SpriteAnimation fireAnimation;
  late SpriteAnimation iceAnimation;
  late SpriteAnimation wallAnimation;
  late SpriteAnimation startAnimation;
  late SpriteAnimation endAnimation;
  late SpriteAnimation bombAnimation;
  late SpriteAnimation dirtAnimation;
  late SpriteAnimation floorAnimation;
  late SpriteAnimation rubbleAnimation;
  late SpriteAnimation emptyEnemyAnimation;
  late SpriteComponent gameBackground;
  late SpriteAnimation sandClockPowerUp;
  late SpriteAnimation potionEnergyPowerUp;
  late SpriteAnimation coinPowerUp;
  late SpriteAnimation scoreIcon;
  late SpriteAnimation relicPowerTreasure;
  late SpriteAnimation walkingArea;

  

  late SpriteAnimation gemRelicRuby;
  late SpriteAnimation gemRelicPearl;
  late SpriteAnimation gemRelicEmerald;
  late SpriteAnimation graveAnimation;
  late SpriteAnimation graveBrokenAnimation;
 

  @override
  Future<void> preloadAnimations(RevaliaObs gameRef) async {

 

    walkingArea = await gameRef.loadSpriteAnimation(
      Assets.resources.images.walkingArea.path,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    ); 

   gameBackground = await getSpriteComponent(
        path: Assets.resources.images.gameBackground32x32.path,
        imgSize: gameRef.camDimension * 4);

    fireAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.FIRE),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    graveAnimation = await gameRef.loadSpriteAnimation(
      Assets.resources.images.graveStill32x321.path,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    graveBrokenAnimation = await gameRef.loadSpriteAnimation(
      Assets.resources.images.gravelTombBreak32x328.path,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );
    

    gemRelicEmerald = await gameRef.loadSpriteAnimation(
      Assets.resources.images.gem3GlowingSheet32x325.path,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

     gemRelicPearl = await gameRef.loadSpriteAnimation(
      Assets.resources.images.gem2GlowingSheet32x323.path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

     gemRelicRuby = await gameRef.loadSpriteAnimation(
      Assets.resources.images.gem1GlowingSheet32x324.path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    relicPowerTreasure = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.RELIC),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.25,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    
    scoreIcon = await gameRef.loadSpriteAnimation(
      Assets.resources.images.scoreiconSheet.path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.55,
        textureSize: Vector2(32, 32),
        loop: false,
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

     fireAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.FIRE),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

     fireAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.FIRE),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    iceAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.ICE),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    wallAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.WALL),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.2,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    startAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.PLAYER),
      SpriteAnimationData.sequenced(
        amount: 16,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    endAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.END),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    bombAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.BOMB),
      SpriteAnimationData.sequenced(
        amount: 29,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    dirtAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.DIRT),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    floorAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.FLOOR),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    rubbleAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.RUBBLE),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    emptyEnemyAnimation = await gameRef.loadSpriteAnimation(
      getSpritePath(ActorModel.EMPTY_ENEMY),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(48, 48),
        loop: false,
      ),
    );

    print("All card animations preloaded successfully.");
  }

  @override
  String getSpritePath(int type) {
    switch (type) {
      case ActorModel.FIRE:
        return Assets.resources.images.cellfireAnimation.path;
      case ActorModel.ICE:
        return Assets.resources.images.cellcoldAnimation.path;
      case ActorModel.WALL:
        return Assets.resources.images.cellrockAnimation.path;
      case ActorModel.PLAYER:
        return Assets.resources.images.start.path;
      case ActorModel.END:
        return Assets.resources.images.end.path;
      case ActorModel.BOMB:
        return Assets.resources.images.bombIconAnim.path;
      case ActorModel.DIRT:
        return Assets.resources.images.cellcoldDirt.path;
      case ActorModel.FLOOR:
        return Assets.resources.images.cellcoldFloor.path;
      case ActorModel.RUBBLE:
        return Assets.resources.images.celldarkDirt.path;
      case ActorModel.EMPTY_ENEMY:
        return Assets.resources.images.blacksquare48x48.path;
       case ActorModel.RELIC:
        return Assets.resources.images.celldarkDirtRelicSheet.path;  
      default:
        throw Exception('Unknown CardType: $type');
    }
  }
  
  @override
  SpriteAnimation getAnimation(int modelValue) {
    print("getAnimation modelValue $modelValue");
    switch (modelValue) {
      case ActorModel.FIRE:
        return fireAnimation;
      case ActorModel.ICE:
        return iceAnimation;
      case ActorModel.WALL:
        return wallAnimation;
      case ActorModel.PLAYER:
        return startAnimation;
      case ActorModel.END:
        return endAnimation;
      case ActorModel.BOMB:
        return bombAnimation;
      case ActorModel.DIRT:
        return dirtAnimation;
      case ActorModel.FLOOR:
        return floorAnimation;
      case ActorModel.RUBBLE:
        return rubbleAnimation;
      case ActorModel.EMPTY_ENEMY:
        return emptyEnemyAnimation;
      case ActorModel.RELIC:
        return relicPowerTreasure;
      case ActorModel.BROKEN_GRAVE:
        return graveBrokenAnimation; 
      case ActorModel.GRAVE:
        return graveAnimation;   
      default:
        throw Exception('Unknown CardType: $modelValue');
    }
  }
  
@override
  Future<SpriteComponent> getSpriteComponent({required String path, required Vector2 imgSize})async {
    Sprite sprite = await SpriteAnimatorCache.loadSprite(path);
    return SpriteComponent(sprite: sprite, size: imgSize);
  }

  @override
  Future<void> preloadSprites(RevaliaObs gameRef) async{
        gameBackground = await getSpriteComponent(
        path: Assets.resources.images.gameBackground32x32.path,
        imgSize: gameRef.camDimension);}



}
