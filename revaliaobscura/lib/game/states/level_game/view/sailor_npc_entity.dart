import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/talk_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class SailorNpcEntity extends LevelEntity {
  SailorNpcEntity({
    required super.position,
    required super.size,
  }) : super(
          dialogueActorId: 'old_sailor',
          behaviors: [
            LookActionBehaviour(dialogId: 'player_error_observe'),
            GrabActionBehaviour(dialogId: 'player_error_interact'),
            TalkActionBehaviour(),
            EntityTapBehaviour(),
          ],
        );

  @override
  void onLoad() {
    super.onLoad();
    animationHandler.init(
      idleAnimation: gameRef.entitySpriteCache.npcOldSailorIdle,
      talkAnimation: gameRef.entitySpriteCache.npcOldSailorTalk,
      size: size,
      parent: this,
    );
  }
}
