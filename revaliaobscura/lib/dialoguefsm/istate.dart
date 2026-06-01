import 'package:revalia/dialoguefsm/dialogue_fsm.dart';

abstract class IDialogueState {
  void enter(DialogueFsm fsm);
  void exit(DialogueFsm fsm);
}
