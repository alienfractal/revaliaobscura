import 'dart:async';
import 'dart:math';
 
import 'package:coolorburn/game/states/game/handlers/player_animation_handler.dart';
import 'package:coolorburn/game/states/game/model/player_model.dart';
import 'package:coolorburn/game/states/game/services/player_logic_service.dart';
 
import 'package:coolorburn/game/states/game/view/cardview.dart';
import 'package:coolorburn/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
class PlayerView extends PositionedEntity with HasGameRef<RevaliaObs> {

  late PlayerModel playerModel;
  late PlayerLogicService playerLogicService;
  late PlayerAnimationHandler playerAnimationHandler;
  late Point playerStartPoint ;


    PlayerView({required this.playerModel, required super.position})
      : super(anchor: Anchor.center, size: Vector2.all(32)) {
    playerLogicService = PlayerLogicService();
    playerAnimationHandler = PlayerAnimationHandler();
  }

  @override
  void onRemove() {
    super.onRemove();
    playerAnimationHandler.cleanUpAnimations();
    removeFromParent();
  }

    @override
  void onLoad() {
    super.onLoad();
    print("EnemyView onLoad");
    playerAnimationHandler.init(this, gameRef);
    playerStartPoint = position.toPoint() ;
    print("enemy card detected card.position ${playerStartPoint.x} ${playerStartPoint.y}");
 
  }

   @override
  void update(double dt) {
   
    super.update(dt);
    
  }

  void makeVisible(bool visible)
  {
    
  }

    void moveTo(ActorView card) {
  
         // Check if the card is to the left or right of the miner
   if (card.position.x < position.x) {
      // Card is to the left, flip the sprite
      if (!playerAnimationHandler.spriteAnimationComponent.isFlippedHorizontally) {
        playerAnimationHandler.spriteAnimationComponent.flipHorizontallyAroundCenter();
      }
    } else {
      // Card is to the right, make sure the sprite is not flipped
      if (playerAnimationHandler.spriteAnimationComponent.isFlippedHorizontally) {
        playerAnimationHandler.spriteAnimationComponent.flipHorizontallyAroundCenter();
      }
    } 
   position = card.position;
      
    playerModel.x = card.actorModel.x;
    playerModel.y = card.actorModel.y;
  }

}





