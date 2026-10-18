import 'package:revalia/dialoguefsm/dialogue_fsm.dart';
import 'package:revalia/dialoguefsm/istate.dart';

class DialogueCompleted implements IDialogueState {
  @override
  void enter(DialogueFsm fsm) {
    fsm.actions += 'C';
  }

  @override
  void exit(DialogueFsm fsm) {
    fsm.actions += 'X';
  }
}
