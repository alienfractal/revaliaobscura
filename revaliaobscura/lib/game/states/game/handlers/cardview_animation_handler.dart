import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/game/states/game/model/actor_model.dart';
import 'package:coolorburn/game/states/game/view/cardview.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'package:flutter/material.dart';

class ActorAnimationHandler {
  late RevaliaObs gameRef;
  late SpriteAnimationComponent spriteAnimationComponent;

  late bool isAnimating = false;
  late bool isExplodingSFX = false;
  late TimerComponent _blinkTimer;
  late bool blink = false;
  late ActorView cardViewParent;
  late SpriteAnimationTicker? animationTicker;

  ActorAnimationHandler();

  void loadAnimation(
      SpriteAnimation spriteAnimation, Vector2 size, ActorView parent) {
    this.cardViewParent = parent;
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: spriteAnimation,
      size: size,
    );

    parent.add(spriteAnimationComponent);
  }

  void cleanUpAnimations() {
    spriteAnimationComponent.removeFromParent();
   
  }

  Future<void> updateCardStyle(ActorView card) async {
    //print("BLUR CARD VIEW");

    RectangleComponent component = RectangleComponent()
      ..position = Vector2(16, 16)
      ..size = Vector2(31, 31)
      ..paint = Paint()
      ..anchor = Anchor.center;
    component.paint.color = Colors.white;

    /*spriteAnimationComponent.paint.imageFilter = ui.ImageFilter.blur(
          sigmaX: 0.5, sigmaY: 0.5, tileMode: TileMode.clamp);*/

    component.paint.blendMode = BlendMode.overlay;
    /*component.paint.colorFilter =
         ColorFilter.mode(Colors.red, BlendMode.saturation);*/
    await card.add(component);
  }

   void triggerEnemySpawn(){

 if (!isAnimating) {
      isAnimating = true;
      cardViewParent.actorModel.status = ActorModel.BROKEN_GRAVE;

      spriteAnimationComponent.animation =
           gameRef.cardCacheService.graveBrokenAnimation;
      animationTicker = spriteAnimationComponent.animationTicker;
      // Listen for when the attack animation finishes
      animationTicker?.onComplete = () {
        // Once attack is finished, switch back to idle
       
      
        gameRef.gboard.remove(gameRef.gboard.actorView);

        isAnimating = false;
      };
    }
  }

 

  bool isBombCardDone(ActorView cardView) {
    // Implement card validation logic

    if (cardView.actorModel.status == ActorModel.BOMB && isAnimating) {
      //// print(animationTicker?.currentIndex);
      if (spriteAnimationComponent.animationTicker != null &&
          (spriteAnimationComponent.animationTicker?.done() ?? false)) {
        isAnimating = false;
        isExplodingSFX = false;
        //print("isBombCardDone bomb animation completed");

        return true;
      }
    }
    return false;
  }

  // Method to make the card blink once
  void blinkCard(ActorView parent) {
    // Store the original color of the card

    final ColorFilter? originalColorFilter =
        spriteAnimationComponent.paint.colorFilter;
    // Apply the glow effect (let's say we make it white to simulate a glow)
    //spriteAnimationComponent.paint.color = Colors.white.withOpacity(1.0);
    //spriteAnimationComponent.paint.blendMode = BlendMode.overlay;
    spriteAnimationComponent.paint.colorFilter =
        const ColorFilter.mode(Colors.red, BlendMode.saturation);
    // Timer to revert the glow after 0.5 seconds

    _blinkTimer = TimerComponent(
        repeat: false,
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
          spriteAnimationComponent.paint.colorFilter = originalColorFilter;
        });

    parent.add(_blinkTimer);
  }
}
