import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

class GrabActionBehaviour extends EntityActionBehaviour {
  final String dialogId;

  GrabActionBehaviour({required this.dialogId});

  @override
  ActionableType get actionType => ActionableType.touch;

  @override
  void execute() {
    game.gboard.callRenderDialogueOnError(dialogId);
  }
}
