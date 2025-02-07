 

import 'package:coolorburn/utils/ui/game_generic_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EntityUIManager {
 
  void blurCard(Vector2 position, Vector2 size) {
    // Implement blurring or other UI effects
  }


// Method to make the card blink once
  static void  blinkEntity(GenericButton parent) {
    // Store the original color of the card
    TimerComponent  blinkTimer;
    final ColorFilter? originalColorFilter =
        parent. spriteComponent.paint.colorFilter;
    // Apply the glow effect (let's say we make it white to simulate a glow)
    //spriteAnimationComponent.paint.color = Colors.white.withOpacity(1.0);
    //spriteAnimationComponent.paint.blendMode = BlendMode.overlay;
    parent.spriteComponent. paint.colorFilter =
        const ColorFilter.mode(Colors.black, BlendMode.saturation);
    // Timer to revert the glow after 0.5 seconds

    blinkTimer = TimerComponent(
        repeat: false,
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
           parent.spriteComponent.paint.colorFilter = originalColorFilter;
        });

    parent.add(blinkTimer);
  }
}
