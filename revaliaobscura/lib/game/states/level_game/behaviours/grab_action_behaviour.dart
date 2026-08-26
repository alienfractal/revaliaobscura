import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class GrabActionBehaviour extends EntityActionBehaviour {
  @override
  ActionableType get actionType => ActionableType.touch;

  @override
  void execute() {
    parent.showInteractionReaction(actionType);
  }
}
