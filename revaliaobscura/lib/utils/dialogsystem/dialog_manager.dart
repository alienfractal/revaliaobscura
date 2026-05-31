import 'package:revalia/utils/dialogsystem/dialog_event_manager.dart';
import 'package:revalia/utils/dialogsystem/dialog_renderer.dart';
import 'package:revalia/utils/dialogsystem/dialogue.dart';

enum DialogState { inactive, active, end }

class DialogueManager {
  static DialogState dialogState = DialogState.inactive;
  static final Map<String, Dialogue> dialogues = {};

  /// Loads dialogues from a flattened JSON structure.
  static void loadDialogues(Map<String, String> flatJson) {
    dialogues.clear();
    for (var key in flatJson.keys) {
      if (key.startsWith("dialogues.") && key.endsWith(".text")) {
        String dialogueId = key.split(".")[1];
        dialogues[dialogueId] = Dialogue.fromJson(dialogueId, flatJson);
      }
    }
  }

  /// Starts a new dialogue and returns it.
  static Dialogue startDialogue(String dialogueId) {
    if (!dialogues.containsKey(dialogueId)) {
      print("❌ Dialogue not found: $dialogueId");
      dialogState = DialogState.inactive;
      return Dialogue(id: "error",player_text: "Dialogue Player_text not found", text: "Dialogue not found: $dialogueId", responses: []);
    }

    dialogState = DialogState.active;
    DialogEventManager.notifycation(event: "start");

    Dialogue dialogue = dialogues[dialogueId]!;
    processDialogue(dialogue);

    return dialogue;
  }

  /// Processes and displays the current dialogue.
  static void processDialogue(Dialogue dialogue) {
    print("🎭 Processing dialogue: ${dialogue.text}");
    DialogueRenderer.showDialogueConsole(dialogue);

    if (dialogue.event != null) {
      DialogEventManager.notifycation(event: dialogue.event!);
    }
  }

  /// Handles player choosing a response.
  static String chooseResponse(Dialogue dialogue, int index) {
    if (dialogState == DialogState.inactive) {
      print("❌ No active dialogue.");
      return DialogState.inactive.toString();
    }

    if (index < 0 || index >= dialogue.responses.length) {
      print("❌ Invalid response index: $index");
      return "Invalid";
    }

    DialogueResponse response = dialogue.responses[index];
    DialogEventManager.notifycation(event: "chooseResponse $index");

    if (response.event != null) {
      DialogEventManager.notifycation(event: response.event!);
    }

    return response.next;
  }

  /// Ends the current dialogue.
  static void endDialogue() {
    print("🏁 Dialogue ended.");
    DialogEventManager.notifycation(event: "end");
    dialogState = DialogState.inactive;
  }
}
