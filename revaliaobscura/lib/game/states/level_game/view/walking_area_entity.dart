import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/move_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class WalkingAreaEntity extends LevelEntity {
  WalkingAreaEntity({
    required super.position,
    required super.size,
  }) : super(
          behaviors: [
            LookActionBehaviour(dialogId: 'player_error_observe'),
            GrabActionBehaviour(dialogId: 'player_error_interact'),
            MoveActionBehaviour(),
          ],
        );

  @override
  void onLoad() {
    super.onLoad();
    animationHandler.init(
      idleAnimation: gameRef.entitySpriteCache.walkingArea,
      size: Vector2(256, 32),
      parent: this,
    );
  }
}
