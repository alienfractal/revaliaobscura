import 'package:coolorburn/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class GameBackgroundTapComponent extends SpriteComponent with TapCallbacks,PointerMoveCallbacks, HasGameRef<RevaliaObs>{
  GameBackgroundTapComponent(SpriteComponent componentSprite)
      : super(sprite:componentSprite.sprite, size: componentSprite.size) {
    
    // Set the size and position if necessary
   // Adjust to cover the entire game area
  }

  @override
  void onTapDown(TapDownEvent event) {
     //print('Background tapped');
    super.onTapDown(event);
  }
  @override
  void onPointerMove(PointerMoveEvent event) {
  }
}
