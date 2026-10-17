import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/ui/game_generic_button.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class CrtShaderButtonTapHandler extends Behavior<GenericButton>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  @override
  void onMount() {
    super.onMount();
    _syncVisualState();
  }

  @override
  void onTapDown(TapDownEvent event) {
    parent.playTapAnimation();
    gameRef.toggleCrtShader();
    _syncVisualState();
    super.onTapDown(event);
  }

  void _syncVisualState() {
    parent.visualPaint.colorFilter = gameRef.isCrtShaderActive
        ? null
        : const ColorFilter.mode(Colors.grey, BlendMode.srcATop);
  }
}
