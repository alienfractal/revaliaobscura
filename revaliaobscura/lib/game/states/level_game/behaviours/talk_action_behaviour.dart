import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class TalkActionBehaviour extends EntityActionBehaviour {
  final String outOfRangeDialogId;
  final String unavailableDialogId;

  TalkActionBehaviour({
    this.outOfRangeDialogId = 'player_error_talk',
    this.unavailableDialogId = 'player_error_interact',
  });

  @override
  ActionableType get actionType => ActionableType.talk;

  @override
  bool get requiresInteractionRange => true;

  @override
  void execute() {
    if (!parent.isPlayerWithinInteractionRange()) {
      game.gboard.callRenderDialogueOnError(outOfRangeDialogId);
      return;
    }

    if (!parent.canTalk) {
      game.gboard.callRenderDialogueOnError(unavailableDialogId);
      return;
    }

    game.gboard.callRenderDialogue(parent);
  }
}
