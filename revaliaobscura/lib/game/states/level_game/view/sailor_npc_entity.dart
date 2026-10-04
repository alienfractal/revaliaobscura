import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/talk_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class SailorNpcEntity extends LevelEntity {
  SailorNpcEntity({
    required Vector2 feetPosition,
    required Vector2 size,
    required String interactionId,
    required String dialogueActorId,
    bool isWalkable = false,
    this.scalesWithPerspective = true,
    this.sortsWithDepth = true,
  }) : super(
          position: feetPosition - Vector2(0, size.y / 2),
          size: size,
          interactionId: interactionId,
          dialogueActorId: dialogueActorId,
          isWalkable: isWalkable,
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
      idleAnimation: game.entitySpriteCache.npcOldSailorIdle.animation,
      talkAnimation: game.entitySpriteCache.npcOldSailorTalk.animation,
      attackAnimation: game.entitySpriteCache.npcOldSailorAttack.animation,
      size: size,
      parent: this,
    );
  }
}
