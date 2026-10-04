import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class EntityTapBehaviour extends Behavior<LevelEntity>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  static int tapCount = 0;

  @override
  void onMount() {
    super.onMount();
    tapCount = 0;
    gameRef.gboard.isEnemyDefeated = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    RevaliaObs.logger.d("TAP DOWN");
    tapCount++;
    parseTapLocation(event);
  }

  void parseTapLocation(TapDownEvent event) {
    print(
        "event.localPosition ${event.localPosition.x} ${event.localPosition.y}");

    if (gameRef.gboard.actionType == ActionableType.move && parent.isWalkable) {
      final destination = parent.absolutePositionOf(event.localPosition);
      if (gameRef.gboard.playerEntity.requestMove(destination)) {
        gameRef.ap.playSoundFx(Assets.resources.audio.select);
      }
      return;
    }

    if (gameRef.gboard.playerEntity.requestActorAction(
      actionType: gameRef.gboard.actionType,
      target: parent,
    )) {
      gameRef.ap.playSoundFx(Assets.resources.audio.select);
    }
  }
}
