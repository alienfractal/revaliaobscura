import 'dart:ui';

import 'package:coolorburn/revalia_obs.dart';
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
  static Future<Sprite> loadSprite(String path) async {
    Image image = await Flame.images.load(path);
    return Sprite(image);
  }

}

abstract class SpriteCache {
   Future<SpriteComponent>  getSpriteComponent({required String path, required Vector2 imgSize});
   Future<void> preloadSprites(RevaliaObs gameRef); 
}
