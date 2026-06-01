import 'package:revalia/game/states/game/view/actorentity.dart';
import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';

class DialogueRenderer {
  static void showDialogueConsole(Dialogue dialogue) {
    // Display NPC dialogue text
    print("${dialogue.id}: ${dialogue.text}");
    // Display response options
    for (int i = 0; i < dialogue.responses.length; i++) {
      print("$i: ${dialogue.responses[i].text}");
    }
  }

  static void showDialogonComponent(ActorEntity actor) {
    final dialogueActorId = actor.dialogueActorId;
    if (dialogueActorId != null) {
      DialogueManager.startConversation(dialogueActorId);
    }
  }
}
