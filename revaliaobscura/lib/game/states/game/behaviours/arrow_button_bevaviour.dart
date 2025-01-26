import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/game_generic_button.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum ArrowDirection { left, right, up, down }

class ArrowButtonTapHandler extends Behavior<GenericButton>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  late ArrowDirection arrowDirection;

  ArrowButtonTapHandler({required this.arrowDirection}) : super();
  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event) {
    double xoffset = 50;
    double yoffset = 50;

    // Example: Scale the button as an animation effect
    if (arrowDirection == ArrowDirection.left) {
      parent.gameRef.cam.moveBy(Vector2(-xoffset, 0), speed: 500);
    } else if (arrowDirection == ArrowDirection.right) {
      parent.gameRef.cam.moveBy(Vector2(xoffset, 0), speed: 500);
    } else if (arrowDirection == ArrowDirection.up) {
      parent.gameRef.cam.moveBy(Vector2(0, -yoffset), speed: 500);
    } else if (arrowDirection == ArrowDirection.down) {
      parent.gameRef.cam.moveBy(Vector2(0, yoffset), speed: 500);
    }

    super.onTapDown(event);
  }
}
