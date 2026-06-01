import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/dialoguefsm/dialogue_fsm.dart';
import 'package:revalia/utils/dialogsystem/dialog_event_manager.dart';
import 'package:revalia/utils/dialogsystem/dialog_renderer.dart';

class DialogueManager {
  static final DialogueFsm fsm = DialogueFsm();

  static Future<void> loadDialogueGraph({
    required String assetPath,
    required Map<String, String> translations,
  }) async {
    final source = await rootBundle.loadString(assetPath);
    fsm.configure(
      graph: jsonDecode(source) as Map<String, dynamic>,
      translations: translations,
    );
  }

  static void setTranslations(Map<String, String> translations) {
    fsm.setTranslations(translations);
  }

  static bool canStartConversation(String actorId) {
    return fsm.canStartConversation(actorId);
  }

  static Dialogue startConversation(String actorId) {
    final dialogue = fsm.startConversation(actorId);
    DialogEventManager.notifycation(event: 'conversation_start:$actorId');
    _processDialogue(dialogue);
    return dialogue;
  }

  static Dialogue startDialogue(String dialogueId) {
    final dialogue = fsm.showNode(dialogueId);
    _processDialogue(dialogue);
    return dialogue;
  }

  static String chooseResponse(Dialogue dialogue, int index) {
    final selection = fsm.chooseResponse(dialogue, index);
    DialogEventManager.notifycation(
      event: 'choose_response:${selection.response.id}',
    );
    if (selection.response.event != null) {
      DialogEventManager.notifycation(event: selection.response.event!);
    }
    return selection.next;
  }

  static void endDialogue() {
    fsm.endConversation();
    DialogEventManager.notifycation(event: 'conversation_end');
  }

  static void resetProgress() {
    fsm.resetProgress();
  }

  static void _processDialogue(Dialogue dialogue) {
    DialogueRenderer.showDialogueConsole(dialogue);
    if (dialogue.event != null) {
      DialogEventManager.notifycation(event: dialogue.event!);
    }
  }
}
