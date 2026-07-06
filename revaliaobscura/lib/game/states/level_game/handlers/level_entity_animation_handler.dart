import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class LevelEntityAnimationHandler {
  late SpriteAnimationComponent spriteAnimationComponent;
  late SpriteAnimation idleAnimation;
  SpriteAnimation? talkAnimation;
  SpriteAnimationTicker? animationTicker;
  bool isAnimating = false;

  void init({
    required SpriteAnimation idleAnimation,
    required Vector2 size,
    required Component parent,
    SpriteAnimation? talkAnimation,
  }) {
    this.idleAnimation = idleAnimation;
    this.talkAnimation = talkAnimation;
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: idleAnimation,
      size: size,
    );
    parent.add(spriteAnimationComponent);
  }

  void cleanUpAnimations() {
    spriteAnimationComponent.removeFromParent();
  }

  void showTalk() {
    final animation = talkAnimation;
    if (animation == null) {
      return;
    }
    isAnimating = true;
    spriteAnimationComponent.animation = animation;
    animationTicker = spriteAnimationComponent.animationTicker;
  }

  void showIdle() {
    isAnimating = false;
    spriteAnimationComponent.animation = idleAnimation;
    animationTicker = spriteAnimationComponent.animationTicker;
  }
}
