 

import 'package:coolorburn/game/states/game/view/actorentity.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CardUIManager {
  void blurCard(Vector2 position, Vector2 size) {
    // Implement blurring or other UI effects
  }


   Future<void> updateCardStyle(ActorPosEntity card) async{
   // print("BLUR CARD VIEW");
    
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
}
