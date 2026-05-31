// Example Behavior class for Card

import 'package:revalia/game/states/game/view/actorentity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class ActorBehavior extends Behavior<ActorEntity>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  static int tapCount = 0;

  @override
  void onMount() {
    // TODO: implement onMount
    super.onMount();
    tapCount = 0;
    gameRef.gboard.isEnemyDefeated = false;
  }

  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    RevaliaObs.logger.d("TAP DOWN");
    tapCount++;
    parseTapLocation(event);
  }

  void parseTapLocation(TapDownEvent event) {
    var absPos = parent.absolutePositionOf(event.localPosition);

    print(
        "event.localPosition ${event.localPosition.x} ${event.localPosition.y}");

    print(
        "parent.absolutePositionOf(event.localPosition)  ${absPos.x} ${absPos.y}");

    //gameRef.gboard.playerView.position =absPos;
    if (gameRef.gboard.actionType == ActionableType.move) {
      print("move");
      if (gameRef.gboard.playerEntity.requestMove(absPos)) {
        gameRef.ap.playSoundFx(Assets.resources.audio.select);
      }
    } else if (gameRef.gboard.playerEntity.requestActorAction(
      actionType: gameRef.gboard.actionType,
      target: parent,
      interactionPosition: absPos,
    )) {
      gameRef.ap.playSoundFx(Assets.resources.audio.select);
    }
  }
}
