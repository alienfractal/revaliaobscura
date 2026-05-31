import 'dart:convert';

import 'package:revalia/utils/dialogsystem/dialog_event_manager.dart';
import 'package:revalia/utils/dialogsystem/dialog_renderer.dart';
import 'package:revalia/utils/dialogsystem/dialogue.dart';
import 'package:flutter/services.dart' show rootBundle;

enum DialogState { inactive, active, end }

class DialogueManager {
  static DialogState dialogState = DialogState.inactive;
  static final Map<String, Dialogue> dialogues = {};
  static Map<String, dynamic> _graphNodes = {};

  static Future<void> loadDialogueGraph({
    required String assetPath,
    required Map<String, String> translations,
  }) async {
    final source = await rootBundle.loadString(assetPath);
    final graph = jsonDecode(source) as Map<String, dynamic>;
    _graphNodes = graph['dialogues'] as Map<String, dynamic>? ?? {};
    _validateGraph();
    setTranslations(translations);
  }

  static void setTranslations(Map<String, String> translations) {
    dialogues
      ..clear()
      ..addEntries(
        _graphNodes.entries.map(
          (entry) => MapEntry(
            entry.key,
            Dialogue.fromGraph(
              id: entry.key,
              graphNode: entry.value as Map<String, dynamic>,
              translations: translations,
            ),
          ),
        ),
      );
  }

  static void _validateGraph() {
    for (final entry in _graphNodes.entries) {
      final node = entry.value as Map<String, dynamic>;
      final responses = node['responses'] as List<dynamic>? ?? [];
      for (final response in responses) {
        final next = (response as Map<String, dynamic>)['next'] as String?;
        if (next == null) {
          throw FormatException(
              'Dialogue "${entry.key}" has a response without "next".');
        }
        if (next != 'end' && !_graphNodes.containsKey(next)) {
          throw FormatException(
              'Dialogue "${entry.key}" points to missing node "$next".');
        }
      }
    }
  }

  static Dialogue startDialogue(String dialogueId) {
    if (!dialogues.containsKey(dialogueId)) {
      print('Dialogue not found: $dialogueId');
      dialogState = DialogState.inactive;
      return Dialogue(
        id: 'error',
        playerText: 'Dialogue player text not found',
        text: 'Dialogue not found: $dialogueId',
        responses: [],
      );
    }

    dialogState = DialogState.active;
    DialogEventManager.notifycation(event: 'start');

    final dialogue = dialogues[dialogueId]!;
    processDialogue(dialogue);

    return dialogue;
  }

  static void processDialogue(Dialogue dialogue) {
    print('Processing dialogue: ${dialogue.text}');
    DialogueRenderer.showDialogueConsole(dialogue);

    if (dialogue.event != null) {
      DialogEventManager.notifycation(event: dialogue.event!);
    }
  }

  static String chooseResponse(Dialogue dialogue, int index) {
    if (dialogState == DialogState.inactive) {
      print('No active dialogue.');
      return DialogState.inactive.toString();
    }

    if (index < 0 || index >= dialogue.responses.length) {
      print('Invalid response index: $index');
      return 'Invalid';
    }

    final response = dialogue.responses[index];
    DialogEventManager.notifycation(event: 'chooseResponse $index');

    if (response.event != null) {
      DialogEventManager.notifycation(event: response.event!);
    }

    return response.next;
  }

  static void endDialogue() {
    print('Dialogue ended.');
    DialogEventManager.notifycation(event: 'end');
    dialogState = DialogState.inactive;
  }
}
