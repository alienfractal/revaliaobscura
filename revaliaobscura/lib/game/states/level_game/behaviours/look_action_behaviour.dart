import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class LookActionBehaviour extends EntityActionBehaviour {
  @override
  ActionableType get actionType => ActionableType.look;

  @override
  void execute() {
    parent.showInteractionReaction(actionType);
  }
}
