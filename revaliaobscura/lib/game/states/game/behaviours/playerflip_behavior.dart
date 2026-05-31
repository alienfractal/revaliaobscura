// Example Behavior class for Card

 
 
import 'package:revalia/game/states/game/view/playerentity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class PlayerBehavior extends Behavior<PlayerPosEntity>
    with TapCallbacks, HasGameRef<RevaliaObs> {

  static int tapCount = 0;
  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event)  {
    super.onTapDown(event);
    RevaliaObs.logger.d("TAP DOWN");

    
     

      gameRef.ap.playSoundFx(Assets.resources.audio.blipSelect2);
      //gameRef.ap.playSoundFx("flip.mp3");
     
  }

 
}
