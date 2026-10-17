import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class TalkActionBehaviour extends EntityActionBehaviour {
  @override
  ActionableType get actionType => ActionableType.talk;

  @override
  bool get requiresInteractionRange => true;

  @override
  void execute() {
    if (!parent.isPlayerWithinInteractionRange()) {
      parent.showInteractionReaction(actionType);
      return;
    }

    if (!parent.canTalk) {
      parent.showInteractionReaction(actionType);
      return;
    }

    game.gboard.callRenderDialogue(parent);
  }
}
