import 'dart:ui';

import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

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

class SpriteSpec {
  final Sprite sprite;
  final Vector2 imgSize;

  SpriteSpec(this.sprite, Vector2 imgSize) : imgSize = imgSize.clone();

  SpriteComponent getSpriteComponent() {
    return SpriteComponent(sprite: sprite, size: imgSize.clone());
  }
}
