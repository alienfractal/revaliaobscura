import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class AnimatedScenePropEntity extends LevelEntity {
  AnimatedScenePropEntity({
    required String interactionId,
    required Vector2 feetPosition,
    required Vector2 visualSize,
    required this.idleAnimation,
    this.scalesWithPerspective = true,
    this.sortsWithDepth = true,
    bool isWalkable = false,
  }) : super(
          interactionId: interactionId,
          isWalkable: isWalkable,
          position: feetPosition - Vector2(0, visualSize.y / 2),
          size: visualSize,
          behaviors: [
            LookActionBehaviour(),
            GrabActionBehaviour(),
            EntityTapBehaviour(),
          ],
        );

  final SpriteAnimation idleAnimation;
  final bool scalesWithPerspective;
  final bool sortsWithDepth;

  @override
  bool get usesPerspectiveScaling => scalesWithPerspective;

  @override
  bool get usesDepthSorting => sortsWithDepth;

  @override
  void onLoad() {
    super.onLoad();
    animationHandler.init(
      idleAnimation: idleAnimation,
      size: size,
      parent: this,
    );
  }
}
