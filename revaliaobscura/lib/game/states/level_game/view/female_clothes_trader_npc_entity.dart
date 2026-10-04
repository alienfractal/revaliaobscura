import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/talk_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class FemaleClothesTraderNpcEntity extends LevelEntity {
  FemaleClothesTraderNpcEntity({
    required Vector2 feetPosition,
    required Vector2 size,
    required super.interactionId,
    super.isWalkable = false,
    this.scalesWithPerspective = true,
    this.sortsWithDepth = true,
  }) : super(
          position: feetPosition - Vector2(0, size.y / 2),
          size: size,
          behaviors: [
            LookActionBehaviour(),
            GrabActionBehaviour(),
            TalkActionBehaviour(),
            EntityTapBehaviour(),
          ],
        );

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
      idleAnimation:
          game.entitySpriteCache.npcFemaleClothesTraderIdle.animation,
      size: size,
      parent: this,
    );
  }
}
