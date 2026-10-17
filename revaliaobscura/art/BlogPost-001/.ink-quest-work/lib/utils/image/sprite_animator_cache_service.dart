import 'dart:ui';

import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

abstract class SpriteAnimatorCache {
  Future<void> preloadAnimations(RevaliaObs gameRef);
  String getSpritePath(int type);
  SpriteAnimation getAnimation(int modelValue);

  static final List<SpriteAnimatorCache> instances = [];
  void registerCache() {
    instances.add(this);
  }

  // Utility method to load different sprites
  static Future<Sprite> loadSprite({required String path}) async {
    Image image = await Flame.images.load(path);
    return Sprite(image);
  }

  SpriteComponent getSpriteComponent(
      {required Sprite sprite, required Vector2 imgSize});

  Future<void> preloadSprites(RevaliaObs gameRef);
}

class StaticSprite {
  final Sprite sprite;
  final Vector2 imgSize;

  StaticSprite(this.sprite, Vector2 imgSize) : imgSize = imgSize.clone();

  SpriteComponent getSpriteComponent() {
    return SpriteComponent(sprite: sprite, size: imgSize.clone());
  }
}

class AnimatedSprite {
  final SpriteAnimation animation;
  final Vector2 imgSize;

  AnimatedSprite(this.animation, Vector2 imgSize) : imgSize = imgSize.clone();

  SpriteAnimationComponent getSpriteAnimationComponent() {
    return SpriteAnimationComponent(
      animation: animation,
      size: imgSize.clone(),
    );
  }
}

class CachedSpriteSheet {
  final SpriteSheet spriteSheet;
  final Vector2 imgSize;
  final int columns;
  final int rows;

  CachedSpriteSheet({
    required this.spriteSheet,
    required Vector2 imgSize,
    required this.columns,
    required this.rows,
  }) : imgSize = imgSize.clone();
}

class CachedAnimatedButtonSprite {
  final Sprite idleSprite;
  final SpriteAnimation tapAnimation;
  final Vector2 buttonSize;
  final Vector2 frameSize;

  CachedAnimatedButtonSprite({
    required this.idleSprite,
    required this.tapAnimation,
    required Vector2 buttonSize,
    required Vector2 frameSize,
  })  : buttonSize = buttonSize.clone(),
        frameSize = frameSize.clone();
}
