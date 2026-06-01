import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/dialoguefsm/dialogue_fsm.dart';

void main() {
  test('conversation flow selects entrypoints from persistent story state', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    expect(fsm.currentStateType, DialogueStateType.inactive);

    final intro = fsm.startConversation('old_sailor');
    expect(fsm.currentStateType, DialogueStateType.active);
    expect(intro.id, 'npc_intro');
    expect(fsm.activeSession?.currentNodeId, 'npc_intro');

    final askIdentity = fsm.chooseResponse(intro, 0);
    expect(askIdentity.next, 'npc_identity');
    expect(fsm.storyState.flag('sailor_identity_known'), isTrue);

    final identity = fsm.showNode(askIdentity.next);
    expect(identity.id, 'npc_identity');
    expect(fsm.activeSession?.history, ['npc_intro']);

    final finishIdentity = fsm.chooseResponse(identity, 0);
    expect(finishIdentity.next, 'end');
    fsm.endConversation();
    expect(fsm.currentStateType, DialogueStateType.completed);

    final laterConversation = fsm.startConversation('old_sailor');
    expect(laterConversation.id, 'npc_after_identity');

    fsm.resetProgress();
    expect(fsm.currentStateType, DialogueStateType.inactive);
    expect(fsm.storyState.flag('sailor_identity_known'), isFalse);
    expect(fsm.startConversation('old_sailor').id, 'npc_intro');
  });

  test('one-time responses are hidden after selection', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    final intro = fsm.startConversation('old_sailor');
    fsm.chooseResponse(intro, 0);

    final rebuiltIntro = fsm.showNode('npc_intro');
    expect(
      rebuiltIntro.responses.map((response) => response.id),
      ['leave'],
    );
  });
}

final Map<String, dynamic> _graph = {
  'actors': {
    'old_sailor': {
      'id': 'old_sailor',
      'name_key': 'actors.old_sailor.name',
      'entrypoints': [
        {
          'dialogue': 'npc_after_identity',
          'when': {'flag': 'sailor_identity_known'},
        },
        {'dialogue': 'npc_intro'},
      ],
    },
  },
  'dialogues': {
    'npc_intro': {
      'responses': [
        {
          'id': 'ask_identity',
          'once': true,
          'effects': [
            {'set_flag': 'sailor_identity_known'},
          ],
          'next': 'npc_identity',
        },
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_identity': {
      'responses': [
        {'id': 'finish_identity', 'next': 'end'},
      ],
    },
    'npc_after_identity': {
      'responses': [
        {'id': 'leave', 'next': 'end'},
      ],
    },
  },
};

final Map<String, String> _translations = {
  'dialogues.npc_intro.player_text': 'Hello.',
  'dialogues.npc_intro.text': 'Welcome.',
  'dialogues.npc_intro.responses[0].text': 'Who are you?',
  'dialogues.npc_intro.responses[1].text': 'Goodbye.',
  'dialogues.npc_identity.player_text': 'Who are you?',
  'dialogues.npc_identity.text': 'A navigator.',
  'dialogues.npc_identity.responses[0].text': 'Thanks.',
  'dialogues.npc_after_identity.player_text': 'Hello again.',
  'dialogues.npc_after_identity.text': 'Any work?',
  'dialogues.npc_after_identity.responses[0].text': 'Goodbye.',
};
