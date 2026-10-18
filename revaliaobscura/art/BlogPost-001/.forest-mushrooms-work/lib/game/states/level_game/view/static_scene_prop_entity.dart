import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

/// An artist can place a pickup with a PNG path in the scenario JSON.
class StaticScenePropEntity extends LevelEntity {
  final String assetPath;
  final bool scalesWithPerspective;
  final bool sortsWithDepth;

  StaticScenePropEntity({
    required this.assetPath,
    required super.interactionId,
    required Vector2 feetPosition,
    required Vector2 visualSize,
    required this.scalesWithPerspective,
    required this.sortsWithDepth,
    super.isWalkable,
  }) : super(
          position: feetPosition - Vector2(0, visualSize.y / 2),
          size: visualSize,
          behaviors: [
            LookActionBehaviour(),
            GrabActionBehaviour(),
            EntityTapBehaviour()
          ],
        );

  @override
  bool get usesPerspectiveScaling => scalesWithPerspective;

  @override
  bool get usesDepthSorting => sortsWithDepth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite(assetPath);
    animationHandler.init(
      idleAnimation: SpriteAnimation.spriteList([sprite], stepTime: 1),
      size: size,
      parent: this,
    );
  }
}
