import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class MoveActionBehaviour extends Behavior<LevelEntity>
    with TapCallbacks, HasGameReference<RevaliaObs> {
  static int tapCount = 0;

  @override
  void onMount() {
    super.onMount();
    tapCount = 0;
    game.gboard.isEnemyDefeated = false;
  }

  @override
  void update(double dt) {}

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    tapCount++;
    parseTapLocation(event);
  }

  void parseTapLocation(TapDownEvent event) {
    var absPos = parent.absolutePositionOf(event.localPosition);

    if (game.gboard.actionType == ActionableType.move) {
      if (game.gboard.playerEntity.requestMove(absPos)) {
        game.ap.playSoundFx(Assets.resources.audio.select);
      }
    } else if (game.gboard.actionType == ActionableType.talk) {
      parent.performAction(ActionableType.talk);
    } else if (game.gboard.playerEntity.requestActorAction(
      actionType: game.gboard.actionType,
      target: parent,
    )) {
      game.ap.playSoundFx(Assets.resources.audio.select);
    }
  }
}
