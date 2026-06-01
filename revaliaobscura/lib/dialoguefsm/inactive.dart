import 'package:revalia/dialoguefsm/dialogue_fsm.dart';
import 'package:revalia/dialoguefsm/istate.dart';

class DialogueInactive implements IDialogueState {
  @override
  void enter(DialogueFsm fsm) {
    fsm.actions += 'I';
  }

  @override
  void exit(DialogueFsm fsm) {
    fsm.actions += 'X';
  }
}
