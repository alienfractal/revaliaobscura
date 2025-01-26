import 'dart:async';

import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/image_utils.dart';
import 'package:flame/components.dart';

import 'package:flame_behaviors/flame_behaviors.dart';

class GenericButton extends PositionedEntity with HasGameRef<RevaliaObs> {
  late SpriteComponent spriteComponent;
  late String buttonIconPath;
  late Behavior behavior;
  late Vector2 buttonPoistion;
  late Vector2 buttonSize;
  late Vector2 tileSize = Vector2(14, 14);
  late bool isTiled = false;
  
  GenericButton(
      {required super.position,
      required this.buttonIconPath,
      required this.behavior,
      required this.buttonSize,
      this.isTiled = false})
      : super(anchor: Anchor.center, size: buttonSize);

  @override
  Future<void> onLoad() async {
    if (isTiled) {
      //spriteComponent = await ImageUtils.createTiledSpriteComponent(
      //    path: buttonIconPath, tileSize: buttonSize, compSize: buttonSize);
     
      List<SpriteComponent> spriteComponents =
          await ComponentUtils.createTiledSpriteComponent(
              path: buttonIconPath,
              tileSize:  tileSize,
              compSize: Vector2(buttonSize.x, buttonSize.y));

      for (var element in spriteComponents) {
        add(element);
        add(behavior);
      }

      return super.onLoad();
    } else {
      spriteComponent = await ComponentUtils.createSpriteComponent(
          path: buttonIconPath, imgSize: buttonSize);
      add(spriteComponent);
      add(behavior);
      return super.onLoad();
    }
  }

  
}
