import 'package:revalia/dialoguefsm/active.dart';
import 'package:revalia/dialoguefsm/completed.dart';
import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/dialoguefsm/dialogue_graph.dart';
import 'package:revalia/dialoguefsm/inactive.dart';
import 'package:revalia/dialoguefsm/istate.dart';
import 'package:revalia/dialoguefsm/story_state.dart';

enum DialogueStateType { inactive, active, completed }

class ConversationSession {
  final String actorId;
  String currentNodeId;
  final List<String> history = [];

  ConversationSession({required this.actorId, required this.currentNodeId});

  void moveTo(String nodeId) {
    history.add(currentNodeId);
    currentNodeId = nodeId;
  }
}

class DialogueSelection {
  final String next;
  final DialogueResponse response;

  DialogueSelection({required this.next, required this.response});
}

class DialogueFsm {
  final StoryState storyState;
  final DialogueInactive inactive = DialogueInactive();
  final DialogueActive active = DialogueActive();
  final DialogueCompleted completed = DialogueCompleted();
  final Map<String, DialogueActorProfile> _actorProfiles = {};
  final Map<String, DialogueObjectProfile> _objectProfiles = {};
  final Map<String, Dialogue> dialogues = {};

  late IDialogueState currentState;
  DialogueStateType currentStateType = DialogueStateType.inactive;
  ConversationSession? activeSession;
  Map<String, dynamic> _graphNodes = {};
  Map<String, String> _translations = {};
  Set<String> _messageIds = {};
  Map<String, String> _fallbackActions = {};
  String actions = '';

  DialogueFsm({StoryState? storyState})
      : storyState = storyState ?? StoryState() {
    currentState = inactive;
    currentState.enter(this);
  }

  void configure({
    required Map<String, dynamic> graph,
    required Map<String, String> translations,
  }) {
    final actorGraphs = graph['actors'] as Map<String, dynamic>? ?? {};
    _actorProfiles
      ..clear()
      ..addEntries(
        actorGraphs.entries.map(
          (entry) => MapEntry(
            entry.key,
            DialogueActorProfile.fromGraph(
              entry.key,
              entry.value as Map<String, dynamic>,
            ),
          ),
        ),
      );
    final objectGraphs = graph['objects'] as Map<String, dynamic>? ?? {};
    _objectProfiles
      ..clear()
      ..addEntries(
        objectGraphs.entries.map(
          (entry) => MapEntry(
            entry.key,
            DialogueObjectProfile.fromGraph(
              entry.key,
              entry.value as Map<String, dynamic>,
            ),
          ),
        ),
      );
    _graphNodes = graph['nodes'] as Map<String, dynamic>? ?? {};
    _messageIds =
        (graph['messages'] as Map<String, dynamic>? ?? {}).keys.toSet();
    _fallbackActions = (graph['fallbacks'] as Map<String, dynamic>? ?? {}).map(
      (action, messageId) {
        if (messageId is! String || messageId.isEmpty) {
          throw FormatException(
            'Fallback action "$action" has an invalid message ID.',
          );
        }
        return MapEntry(action, messageId);
      },
    );
    _translations = translations;
    _validateGraph();
    resetProgress();
  }

  void setTranslations(Map<String, String> translations) {
    _translations = translations;
    _rebuildDialogues();
  }

  bool canStartConversation(String actorId) {
    return _selectEntrypoint(actorId) != null;
  }

  String interactionMessage(String targetId, String action) {
    final messageId = _actorProfiles[targetId]?.actions[action] ??
        _objectProfiles[targetId]?.actions[action] ??
        _fallbackActions[action];
    if (messageId == null) {
      return '[Missing interaction: $targetId.$action]';
    }
    return _translations['messages.$messageId.text'] ??
        '[Missing message: $messageId]';
  }

  String message(String messageId) {
    if (!_messageIds.contains(messageId)) {
      return '[Unknown message: $messageId]';
    }
    return _translations['messages.$messageId.text'] ??
        '[Missing message: $messageId]';
  }

  Dialogue startConversation(String actorId) {
    final entrypoint = _selectEntrypoint(actorId);
    if (entrypoint == null) {
      return _errorDialogue('No available dialogue for actor: $actorId');
    }
    activeSession = ConversationSession(
      actorId: actorId,
      currentNodeId: entrypoint.dialogueId,
    );
    transition(DialogueStateType.active);
    return showNode(entrypoint.dialogueId);
  }

  Dialogue showNode(String dialogueId) {
    if (!_graphNodes.containsKey(dialogueId)) {
      return _errorDialogue('Dialogue not found: $dialogueId');
    }
    final session = activeSession;
    if (session != null && session.currentNodeId != dialogueId) {
      session.moveTo(dialogueId);
    }
    _rebuildDialogues();
    return dialogues[dialogueId]!;
  }

  DialogueSelection chooseResponse(Dialogue dialogue, int index) {
    if (currentStateType != DialogueStateType.active) {
      throw StateError('No active dialogue.');
    }
    if (index < 0 || index >= dialogue.responses.length) {
      throw RangeError.index(index, dialogue.responses, 'index');
    }

    final response = dialogue.responses[index];
    storyState.applyEffects(response.effects);
    if (response.once) {
      storyState.consumeResponse(_responseStateId(dialogue.id, response.id));
    }
    return DialogueSelection(next: response.next, response: response);
  }

  void endConversation() {
    activeSession = null;
    transition(DialogueStateType.completed);
  }

  void resetProgress() {
    storyState.clear();
    activeSession = null;
    transition(DialogueStateType.inactive);
    _rebuildDialogues();
  }

  void transition(DialogueStateType newState) {
    currentState.exit(this);
    switch (newState) {
      case DialogueStateType.inactive:
        currentState = inactive;
        break;
      case DialogueStateType.active:
        currentState = active;
        break;
      case DialogueStateType.completed:
        currentState = completed;
        break;
    }
    currentStateType = newState;
    currentState.enter(this);
  }

  DialogueEntrypoint? _selectEntrypoint(String actorId) {
    final profile = _actorProfiles[actorId];
    if (profile == null) {
      return null;
    }
    for (final entrypoint in profile.entrypoints) {
      if (storyState.matches(entrypoint.condition)) {
        return entrypoint;
      }
    }
    return null;
  }

  void _rebuildDialogues() {
    dialogues
      ..clear()
      ..addEntries(
        _graphNodes.entries.map(
          (entry) => MapEntry(
            entry.key,
            Dialogue.fromGraph(
              id: entry.key,
              graphNode: entry.value as Map<String, dynamic>,
              translations: _translations,
              isResponseAvailable: (responseId, condition, once) {
                if (!storyState.matches(condition)) {
                  return false;
                }
                return !once ||
                    !storyState.isResponseConsumed(
                      _responseStateId(entry.key, responseId),
                    );
              },
            ),
          ),
        ),
      );
  }

  void _validateGraph() {
    for (final profile in _actorProfiles.values) {
      if (profile.entrypoints.isEmpty) {
        throw FormatException(
          'Dialogue actor "${profile.id}" has no entrypoints.',
        );
      }
      for (final entrypoint in profile.entrypoints) {
        if (!_graphNodes.containsKey(entrypoint.dialogueId)) {
          throw FormatException(
            'Dialogue actor "${profile.id}" points to missing node '
            '"${entrypoint.dialogueId}".',
          );
        }
      }
    }

    for (final entry in _graphNodes.entries) {
      final node = entry.value as Map<String, dynamic>;
      final responses = node['responses'] as List<dynamic>? ?? [];
      for (final responseData in responses) {
        final response = responseData as Map<String, dynamic>;
        final id = response['id'] as String?;
        final next = response['next'] as String?;
        if (id == null || next == null) {
          throw FormatException(
            'Dialogue "${entry.key}" has a response without "id" or "next".',
          );
        }
        if (next != 'end' && !_graphNodes.containsKey(next)) {
          throw FormatException(
            'Dialogue "${entry.key}" points to missing node "$next".',
          );
        }
      }
    }

    for (final profile in _actorProfiles.values) {
      for (final messageId in profile.actions.values) {
        _validateMessageId(messageId);
      }
    }
    for (final profile in _objectProfiles.values) {
      for (final messageId in profile.actions.values) {
        _validateMessageId(messageId);
      }
    }
    for (final messageId in _fallbackActions.values) {
      _validateMessageId(messageId);
    }
  }

  void _validateMessageId(String messageId) {
    if (!_messageIds.contains(messageId)) {
      throw FormatException(
        'Interaction points to missing message "$messageId".',
      );
    }
  }

  Dialogue _errorDialogue(String message) {
    activeSession = null;
    transition(DialogueStateType.inactive);
    return Dialogue(
      id: 'error',
      playerText: 'Dialogue player text not found',
      text: message,
      responses: [],
    );
  }

  String _responseStateId(String dialogueId, String responseId) {
    return '$dialogueId.$responseId';
  }
}
