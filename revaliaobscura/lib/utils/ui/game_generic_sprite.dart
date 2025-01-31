import 'dart:async';

import 'package:coolorburn/revalia_obs.dart';

import 'package:flame/components.dart';

import 'package:flame_behaviors/flame_behaviors.dart';

class GenericSpriteAnimation extends PositionedEntity with HasGameRef<RevaliaObs> {
  late SpriteAnimationComponent spriteAnimationComponent;
   // Path to the sprite sheet or animation image
  late Vector2 animationSize; // Size of the animation component
  late int frames; // Number of frames in the animation
  late double stepTime; // Time between each frame in the animation
  late bool loop; // Whether the animation should loop or play once
  late SpriteAnimation spriteAnimation;
  GenericSpriteAnimation({
    required super.position,
    required this.spriteAnimation,
    required this.animationSize,
    required super.behaviors,
    this.stepTime = 0.1,
    this.loop = true,

  }) : super(anchor: Anchor.center, size: animationSize);

  @override
  Future<void> onLoad() async {
    // Load the sprite animation from the given path
    

    // Create the SpriteAnimationComponent to manage the animation
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: spriteAnimation,
      size: animationSize,
    );

    // Add the animation component to this entity
    add(spriteAnimationComponent);

    return super.onLoad();
  }
}
