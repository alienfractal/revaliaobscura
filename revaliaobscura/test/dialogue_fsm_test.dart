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
    expect(fsm.storyState.flag('sailor_identity_known'), isFalse);

    final identity = fsm.showNode(askIdentity.next);
    expect(identity.id, 'npc_identity');
    expect(fsm.activeSession?.history, ['npc_intro']);

    final mockOutfit = fsm.chooseResponse(identity, 0);
    expect(mockOutfit.next, 'npc_silent_stare');

    final silentStare = fsm.showNode(mockOutfit.next);
    final askIfComedian = fsm.chooseResponse(silentStare, 1);
    expect(askIfComedian.next, 'npc_hendrik_identity');
    expect(fsm.storyState.flag('sailor_identity_known'), isTrue);

    final hendrikIdentity = fsm.showNode(askIfComedian.next);
    final leaveIdentity = fsm.chooseResponse(hendrikIdentity, 1);
    expect(leaveIdentity.next, 'end');
    fsm.endConversation();
    expect(fsm.currentStateType, DialogueStateType.completed);

    final laterConversation = fsm.startConversation('old_sailor');
    expect(laterConversation.id, 'npc_after_identity');

    fsm.resetProgress();
    expect(fsm.currentStateType, DialogueStateType.inactive);
    expect(fsm.storyState.flag('sailor_identity_known'), isFalse);
    expect(fsm.startConversation('old_sailor').id, 'npc_intro');
  });

  test('need question is gated behind Hendrik revealing his name', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    final intro = fsm.startConversation('old_sailor');
    expect(
      intro.responses.map((response) => response.id),
      ['ask_identity', 'leave'],
    );

    final identity = fsm.showNode(fsm.chooseResponse(intro, 0).next);
    expect(
      identity.responses.map((response) => response.id),
      ['mock_outfit', 'ask_if_comedian', 'leave'],
    );
  });

  test('asking what the navigator needs starts the ink quest', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    final intro = fsm.startConversation('old_sailor');
    final identity = fsm.showNode(fsm.chooseResponse(intro, 0).next);
    final hendrikIdentity = fsm.showNode(fsm.chooseResponse(identity, 1).next);
    final askNeed = fsm.chooseResponse(hendrikIdentity, 0);
    expect(askNeed.next, 'npc_ask_name');

    final askName = fsm.showNode(askNeed.next);
    final answerName = fsm.chooseResponse(askName, 0);
    expect(answerName.next, 'npc_ink_request');

    final inkRequest = fsm.showNode(answerName.next);
    final acceptQuest = fsm.chooseResponse(inkRequest, 0);
    expect(acceptQuest.next, 'end');
    expect(fsm.storyState.flag('navigator_ink_quest_started'), isTrue);

    fsm.endConversation();
    expect(fsm.startConversation('old_sailor').id, 'npc_waiting_for_ink');
  });

  test('continuing without mocking reveals Hendrik identity', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    final intro = fsm.startConversation('old_sailor');
    final identity = fsm.showNode(fsm.chooseResponse(intro, 0).next);
    final continueConversation = fsm.chooseResponse(identity, 1);

    expect(continueConversation.next, 'npc_hendrik_identity');
    expect(fsm.storyState.flag('sailor_identity_known'), isTrue);
  });

  test('laughing at the navigator outfit triggers honor response', () {
    final fsm = DialogueFsm();
    fsm.configure(graph: _graph, translations: _translations);

    final intro = fsm.startConversation('old_sailor');
    final identity = fsm.showNode(fsm.chooseResponse(intro, 0).next);
    final silentStare = fsm.showNode(fsm.chooseResponse(identity, 0).next);
    final laugh = fsm.chooseResponse(silentStare, 0);
    expect(laugh.next, 'npc_defend_honor');

    final honor = fsm.showNode(laugh.next);
    expect(honor.text, 'I must defend my honor.');
    final apologize = fsm.chooseResponse(honor, 0);
    expect(apologize.next, 'npc_silent_stare');
    final laughAgain = fsm.chooseResponse(honor, 1);
    expect(laughAgain.next, 'end');
  });
}

final Map<String, dynamic> _graph = {
  'actors': {
    'old_sailor': {
      'id': 'old_sailor',
      'name_key': 'actors.old_sailor.name',
      'entrypoints': [
        {
          'dialogue': 'npc_waiting_for_ink',
          'when': {'flag': 'navigator_ink_quest_started'},
        },
        {
          'dialogue': 'npc_after_identity',
          'when': {'flag': 'sailor_identity_known'},
        },
        {'dialogue': 'npc_intro'},
      ],
    },
  },
  'nodes': {
    'npc_intro': {
      'responses': [
        {
          'id': 'ask_identity',
          'next': 'npc_identity',
        },
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_identity': {
      'responses': [
        {'id': 'mock_outfit', 'next': 'npc_silent_stare'},
        {
          'id': 'ask_if_comedian',
          'effects': [
            {'set_flag': 'sailor_identity_known'},
          ],
          'next': 'npc_hendrik_identity',
        },
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_defend_honor': {
      'responses': [
        {'id': 'apologize', 'next': 'npc_silent_stare'},
        {'id': 'laugh_again', 'next': 'end'},
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_silent_stare': {
      'responses': [
        {'id': 'laugh', 'next': 'npc_defend_honor'},
        {
          'id': 'ask_if_comedian',
          'effects': [
            {'set_flag': 'sailor_identity_known'},
          ],
          'next': 'npc_hendrik_identity',
        },
      ],
    },
    'npc_hendrik_identity': {
      'responses': [
        {'id': 'ask_need', 'next': 'npc_ask_name'},
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_ask_name': {
      'responses': [
        {'id': 'answer_rebane', 'next': 'npc_ink_request'},
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_ink_request': {
      'responses': [
        {
          'id': 'accept_ink_quest',
          'effects': [
            {'set_flag': 'navigator_ink_quest_started'},
          ],
          'next': 'end',
        },
      ],
    },
    'npc_after_identity': {
      'responses': [
        {'id': 'ask_need', 'next': 'npc_ask_name'},
        {'id': 'leave', 'next': 'end'},
      ],
    },
    'npc_waiting_for_ink': {
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
  'dialogues.npc_identity.responses[0].text': 'That outfit.',
  'dialogues.npc_identity.responses[1].text': 'Are you a comedian?',
  'dialogues.npc_identity.responses[2].text': 'Goodbye.',
  'dialogues.npc_defend_honor.player_text': 'Hahaha.',
  'dialogues.npc_defend_honor.text': 'I must defend my honor.',
  'dialogues.npc_defend_honor.responses[0].text': 'Sorry.',
  'dialogues.npc_defend_honor.responses[1].text': 'Hahaha.',
  'dialogues.npc_defend_honor.responses[2].text': 'Goodbye.',
  'dialogues.npc_silent_stare.player_text': 'That outfit.',
  'dialogues.npc_silent_stare.text': '...',
  'dialogues.npc_silent_stare.responses[0].text': 'Hahaha.',
  'dialogues.npc_silent_stare.responses[1].text': 'Are you a comedian?',
  'dialogues.npc_hendrik_identity.player_text': 'Are you a comedian?',
  'dialogues.npc_hendrik_identity.text': 'My name is Hendrik.',
  'dialogues.npc_hendrik_identity.responses[0].text': 'What do you need?',
  'dialogues.npc_hendrik_identity.responses[1].text': 'Goodbye.',
  'dialogues.npc_ask_name.player_text': 'What do you need?',
  'dialogues.npc_ask_name.text': 'What is your name?',
  'dialogues.npc_ask_name.responses[0].text': 'Rebane.',
  'dialogues.npc_ask_name.responses[1].text': 'Goodbye.',
  'dialogues.npc_ink_request.player_text': 'Rebane.',
  'dialogues.npc_ink_request.text': 'Bring me ink.',
  'dialogues.npc_ink_request.responses[0].text': 'I will.',
  'dialogues.npc_after_identity.player_text': 'Hello again.',
  'dialogues.npc_after_identity.text': 'Any work?',
  'dialogues.npc_after_identity.responses[0].text': 'What do you need?',
  'dialogues.npc_after_identity.responses[1].text': 'Goodbye.',
  'dialogues.npc_waiting_for_ink.player_text': 'About that ink.',
  'dialogues.npc_waiting_for_ink.text': 'Bring me ink.',
  'dialogues.npc_waiting_for_ink.responses[0].text': 'Goodbye.',
};
