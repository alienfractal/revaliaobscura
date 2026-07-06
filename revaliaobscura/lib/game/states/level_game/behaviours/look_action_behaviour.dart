import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class LookActionBehaviour extends EntityActionBehaviour {
  final String dialogId;

  LookActionBehaviour({required this.dialogId});

  @override
  ActionableType get actionType => ActionableType.look;

  @override
  void execute() {
    game.gboard.callRenderDialogueOnError(dialogId);
  }
}
