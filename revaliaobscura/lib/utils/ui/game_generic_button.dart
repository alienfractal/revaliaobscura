import 'dart:async';
import 'dart:ui';

import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/image/image_utils.dart';
import 'package:flame/components.dart';

import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class GenericButton extends PositionedEntity with HasGameRef<RevaliaObs> {
  late SpriteComponent spriteComponent;
  late Behavior behavior;
  late Vector2 buttonPoistion;
  late Vector2 buttonSize;
  late Vector2 tileSize = Vector2(14, 14);
  late bool isTiled = false;
  late ColorFilter graycolorFilter;
  late ColorFilter originalcolorFilter;
  bool active = true;

  GenericButton(
      {required super.position,
      required this.spriteComponent,
      required this.behavior,
      required this.buttonSize,
      this.isTiled = false})
      : super(anchor: Anchor.center, size: buttonSize);

  @override
  Future<void> onLoad() async {
    graycolorFilter =
        const ColorFilter.mode(Colors.black, BlendMode.saturation);
    originalcolorFilter = 
        const ColorFilter.mode(Colors.white, BlendMode.src);

 
   
    add(spriteComponent);
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
      spriteComponent.paint.colorFilter = null;
    } else {
      spriteComponent.paint.colorFilter = graycolorFilter;
    }
  }
}
