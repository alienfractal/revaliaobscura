import 'package:revalia/dialoguefsm/dialogue_fsm.dart';
import 'package:revalia/dialoguefsm/istate.dart';

class DialogueActive implements IDialogueState {
  @override
  void enter(DialogueFsm fsm) {
    fsm.actions += 'A';
  }

  @override
  void exit(DialogueFsm fsm) {
    fsm.actions += 'X';
  }
}
