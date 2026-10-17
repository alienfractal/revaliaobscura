import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/dialoguefsm/adventure_state.dart';
import 'package:revalia/dialoguefsm/dialogue_fsm.dart';

Map<String, dynamic> loadAdventureGraph() => jsonDecode(
        File('resources/dialogues/revalia_dialogues.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  late DialogueFsm fsm;
  late AdventureState state;
  setUp(() {
    fsm = DialogueFsm()
      ..configure(graph: loadAdventureGraph(), translations: {});
    state = fsm.storyState.adventure;
  });

  test('new game has one permanent scroll and no accepted tasks', () {
    expect(state.inventory, {'task_scroll': 1});
    expect(state.journal, isEmpty);
    expect(state.removeItem('task_scroll'), isFalse);
    state.addItem('task_scroll');
    expect(state.quantity('task_scroll'), 1);
  });

  test('only accepting the actual ink request creates the journal entry', () {
    fsm.startConversation('old_sailor');
    final request = fsm.showNode('npc_ink_request');
    expect(state.journal, isEmpty);
    fsm.chooseResponse(request, 0);
    expect(state.journal.single.id, 'navigator_ink');
    expect(state.status('navigator_ink'), QuestStatus.active);
    fsm.endConversation();
    expect(fsm.startConversation('old_sailor').id, 'npc_waiting_for_ink');
    expect(state.startQuest('navigator_ink'), isFalse);
    expect(state.journal.length, 1);
  });

  test('collecting ink is one-time and readiness follows current inventory',
      () {
    state.startQuest('navigator_ink');
    expect(state.collectPickup('empty_bottle_pickup'), isTrue);
    expect(state.collectPickup('empty_bottle_pickup'), isFalse);
    expect(state.quantity('empty_bottle'), 1);
    state.removeItem('empty_bottle');
    state.addItem('ink_bottle');
    expect(state.status('navigator_ink'), QuestStatus.ready);
    state.removeItem('ink_bottle');
    expect(state.status('navigator_ink'), QuestStatus.active);
  });

  test('wrong recipient and unaccepted quest keep the ink', () {
    state.addItem('ink_bottle');
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNull);
    state.startQuest('navigator_ink');
    expect(state.deliverItem('ink_bottle', 'clothes_trader'), isNull);
    expect(state.quantity('ink_bottle'), 1);
  });

  test('delivery consumes one ink and permanently completes the task', () {
    state.startQuest('navigator_ink');
    state.addItem('ink_bottle', 2);
    expect(state.deliverItem('ink_bottle', 'old_sailor')?.id, 'navigator_ink');
    expect(state.quantity('ink_bottle'), 1);
    expect(state.status('navigator_ink'), QuestStatus.completed);
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNull);
    expect(state.quantity('ink_bottle'), 1);
    expect(fsm.startConversation('old_sailor').id, 'npc_ink_thanks');
  });

  test('dialogue delivery is offered only when the quest is ready', () {
    fsm.startConversation('old_sailor');
    fsm.chooseResponse(fsm.showNode('npc_ink_request'), 0);
    expect(fsm.showNode('npc_waiting_for_ink').responses.map((r) => r.id),
        ['leave']);
    fsm.storyState.applyEffects([
      {'add_item': 'ink_bottle'}
    ]);
    final waiting = fsm.showNode('npc_waiting_for_ink');
    expect(waiting.responses.first.id, 'give_ink');
    expect(fsm.chooseResponse(waiting, 0).next, 'npc_ink_thanks');
    expect(state.status('navigator_ink'), QuestStatus.completed);
    expect(state.hasItem('ink_bottle'), isFalse);
  });

  test('reset clears inventory, pickups and quests, then restores scroll', () {
    state.startQuest('navigator_ink');
    state.collectPickup('empty_bottle_pickup');
    state.completeQuest('navigator_ink');
    fsm.resetProgress();
    expect(state.inventory, {'task_scroll': 1});
    expect(state.journal, isEmpty);
    expect(state.status('navigator_ink'), QuestStatus.available);
    expect(state.collectPickup('empty_bottle_pickup'), isTrue);
  });

  test('invalid quantities and missing quest items are rejected', () {
    expect(() => state.addItem('ink_bottle', 0), throwsArgumentError);
    expect(() => state.removeItem('ink_bottle', -1), throwsArgumentError);
    expect(() => state.addItem('unknown'), throwsArgumentError);
    expect(state.completeQuest('navigator_ink'), isFalse);
    expect(
        () => AdventureState().configure({
              'quests': {
                'broken': {
                  'recipient': 'old_sailor',
                  'required_items': {'missing_item': 1}
                }
              }
            }),
        throwsFormatException);
  });
}
