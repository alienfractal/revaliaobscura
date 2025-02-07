import 'package:coolorburn/utils/dialogsystem/dialog_event_manager.dart';
import 'package:coolorburn/utils/dialogsystem/dialog_renderer.dart';
import 'package:coolorburn/utils/dialogsystem/dialogue.dart';
 

enum DialogState { inactive, start, active, end }

class DialogueManager {
  static DialogState dialogState = DialogState.inactive;
  static Map<String, Dialogue> dialogues = {};
  static Dialogue? activeDialogue;

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

  /// Starts a new dialogue.
  static void startDialogue(String dialogueId) {
    print("🗣️ Starting dialogue: $dialogueId");

    if (!dialogues.containsKey(dialogueId)) {
      print("❌ Dialogue not found: $dialogueId");
      dialogState = DialogState.inactive;
      return;
    }

    dialogState = DialogState.start;
    DialogEventManager.notifycation(event: "start");

    activeDialogue = dialogues[dialogueId];
    processDialogue(activeDialogue!);
  }

  /// Processes and displays the current dialogue.
  static void processDialogue(Dialogue dialogue) {
    print("🎭 Processing dialogue: ${dialogue.text}");
    
    DialogueRenderer.showDialogueConsole(dialogue);
    dialogState = DialogState.active; // ✅ Set state to active

    if (dialogue.event != null) {
      DialogEventManager.notifycation(event: dialogue.event!);
    }
  }

  /// Handles player choosing a response.
  static String chooseResponse(int index) {
    if (dialogState == DialogState.inactive || activeDialogue == null) {
      print("❌ No active dialogue.");
      return "";  // ✅ More consistent than "end"
    }

    if (index < 0 || index >= activeDialogue!.responses.length) {
      print("❌ Invalid response index: $index");
      return "";
    }

    DialogEventManager.notifycation(event: "chooseResponse $index");
    DialogueResponse response = activeDialogue!.responses[index];

    if (response.event != null) {
      DialogEventManager.notifycation(event: response.event!);
    }

    if (response.next == "end") {
      endDialogue();
      return "end";
    } else {
      startDialogue(response.next);
      return response.next;
    }
  }

  /// Ends the current dialogue.
  static void endDialogue() {
    print("🏁 Dialogue ended.");
    DialogEventManager.notifycation(event: "end");
    activeDialogue = null;
    dialogState = DialogState.end;

    // Optionally reset to `inactive` after a delay
    Future.delayed(Duration(seconds: 1), () {
      dialogState = DialogState.inactive;
    });
  }

  /// Prints available responses in the console (for debugging).
  static void listResponses() {
    if (activeDialogue == null) {
      print("❌ No active dialogue.");
      return;
    }

    print("🗣️ Dialogue: ${activeDialogue?.id}");
    print("💬 Text: ${activeDialogue?.text}");
    print("🔽 Available Responses:");

    for (var i = 0; i < activeDialogue!.responses.length; i++) {
      DialogueResponse response = activeDialogue!.responses[i];
      print("  $i: ${response.text} → ${response.next} (event: ${response.event})");
    }
  }
}

