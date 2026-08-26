import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';

class LevelEntityAnimationHandler {
  late SpriteAnimationComponent spriteAnimationComponent;
  late SpriteAnimation idleAnimation;
  SpriteAnimation? talkAnimation;
  SpriteAnimation? attackAnimation;
  SpriteAnimationTicker? animationTicker;
  bool isAnimating = false;

  void init({
    required SpriteAnimation idleAnimation,
    required Vector2 size,
    required Component parent,
    SpriteAnimation? talkAnimation,
    SpriteAnimation? attackAnimation,
  }) {
    this.idleAnimation = idleAnimation;
    this.talkAnimation = talkAnimation;
    this.attackAnimation = attackAnimation;
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: idleAnimation,
      size: size,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y),
    );
    parent.add(spriteAnimationComponent);
  }

  void updatePerspectiveScale(double feetY) {
    final perspectiveScale = PerspectiveConfig.characterScaleForFeetY(feetY);
    final facingDirection =
        spriteAnimationComponent.scale.x.isNegative ? -1.0 : 1.0;
    spriteAnimationComponent.scale.setValues(
      perspectiveScale * facingDirection,
      perspectiveScale,
    );
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

  void showAttack({void Function()? onComplete}) {
    final animation = attackAnimation;
    if (animation == null) {
      onComplete?.call();
      return;
    }
    isAnimating = true;
    spriteAnimationComponent.animation = animation;
    animationTicker = spriteAnimationComponent.animationTicker;
    animationTicker?.onComplete = () {
      showIdle();
      onComplete?.call();
    };
  }
}
