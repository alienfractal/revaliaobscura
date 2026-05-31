import 'dart:async';

import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';

import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class GenericButton extends PositionedEntity with HasGameRef<RevaliaObs> {
  SpriteComponent? spriteComponent;
  SpriteAnimationComponent? animationComponent;
  final String? buttonIconPath;
  late Behavior behavior;
  late Vector2 buttonPoistion;
  late Vector2 buttonSize;
  late Vector2 tileSize = Vector2(14, 14);
  late bool isTiled = false;
  late ColorFilter graycolorFilter;
  late ColorFilter originalcolorFilter;
  final bool isAnimated;
  final int animationFrames;
  final double animationStepTime;
  final Vector2? animationFrameSize;
  Sprite? idleSprite;
  SpriteAnimation? tapAnimation;
  bool active = true;

  GenericButton(
      {required super.position,
      this.spriteComponent,
      this.buttonIconPath,
      required this.behavior,
      required this.buttonSize,
      this.isTiled = false,
      this.isAnimated = false,
      this.animationFrames = 1,
      this.animationStepTime = 0.12,
      this.animationFrameSize})
      : super(anchor: Anchor.center, size: buttonSize);

  @override
  Future<void> onLoad() async {
    graycolorFilter =
        const ColorFilter.mode(Colors.black, BlendMode.saturation);
    originalcolorFilter = const ColorFilter.mode(Colors.white, BlendMode.src);

    if (isAnimated) {
      final path = buttonIconPath;
      if (path == null) {
        throw ArgumentError('Animated buttons require buttonIconPath.');
      }
      idleSprite = await gameRef.loadSprite(
        path,
        srcSize: animationFrameSize ?? buttonSize,
      );
      tapAnimation = await gameRef.loadSpriteAnimation(
        path,
        SpriteAnimationData.sequenced(
          amount: animationFrames,
          stepTime: animationStepTime,
          textureSize: animationFrameSize ?? buttonSize,
          loop: false,
        ),
      );
      animationComponent = SpriteAnimationComponent(
        animation: SpriteAnimation.spriteList(
          [idleSprite!],
          stepTime: animationStepTime,
          loop: false,
        ),
        anchor: Anchor.center,
        position: buttonSize * 0.5,
        size: buttonSize,
      );
      add(animationComponent!);
    } else {
      final sprite = spriteComponent;
      if (sprite == null) {
        throw ArgumentError('Buttons require spriteComponent.');
      }
      add(sprite);
    }
    add(behavior);
    return super.onLoad();
  }

  @override
  void onMount() {
    // TODO: implement onMount
    super.onMount();
  }

  void isActive(bool active) {
    if (active) {
      visualPaint.colorFilter = null;
    } else {
      visualPaint.colorFilter = graycolorFilter;
    }
  }

  Paint get visualPaint => animationComponent?.paint ?? spriteComponent!.paint;

  void playTapAnimation() {
    final component = animationComponent;
    final animation = tapAnimation;
    final idle = idleSprite;
    if (component == null || animation == null || idle == null) {
      return;
    }
    component.animation = animation.clone()..loop = false;
    component.animationTicker?.onComplete = () {
      component.animation = SpriteAnimation.spriteList(
        [idle],
        stepTime: animationStepTime,
        loop: false,
      );
    };
  }
}
