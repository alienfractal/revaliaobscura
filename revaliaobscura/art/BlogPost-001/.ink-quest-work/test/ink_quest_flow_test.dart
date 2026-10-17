import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/dialoguefsm/dialogue_fsm.dart';
import 'package:revalia/dialoguefsm/adventure_state.dart';
import 'package:revalia/game/states/level_game/scenario/quest_locations.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';

void main() {
  late DialogueFsm fsm;
  late Map<String, dynamic> graph;
  setUp(() {
    graph = jsonDecode(File('resources/dialogues/revalia_dialogues.json')
        .readAsStringSync()) as Map<String, dynamic>;
    fsm = DialogueFsm()..configure(graph: graph, translations: {});
  });
  Dialogue choose(Dialogue node, String id) {
    final selection =
        fsm.chooseResponse(node, node.responses.indexWhere((r) => r.id == id));
    if (selection.next == 'end') {
      fsm.endConversation();
      return node;
    }
    return fsm.showNode(selection.next);
  }

  void acceptQuest() {
    var node = fsm.startConversation('old_sailor');
    node = choose(node, 'ask_identity');
    node = choose(node, 'ask_if_comedian');
    node = choose(node, 'ask_need');
    node = choose(node, 'answer_rebane');
    choose(node, 'accept_ink_quest');
  }

  test('full route: quest, lady, bottle, guard, forest, ink and Tartu reward',
      () {
    expect(fsm.canStartConversation('female_clothes_trader'), isFalse);
    acceptQuest();
    var lady = fsm.startConversation('female_clothes_trader');
    expect(lady.id, 'lady_hendrik');
    lady = choose(lady, 'explain_ink');
    expect(lady.id, 'lady_directions');
    choose(lady, 'thank_lady');
    final state = fsm.storyState.adventure;
    expect(state.collectPickup('empty_bottle_pickup'), isTrue);
    expect(state.collectPickup('empty_bottle_pickup'), isFalse);
    expect(state.quantity('empty_bottle'), 1);
    final guard = fsm.startConversation('city_guard');
    choose(guard, 'follow_directions');
    expect(fsm.storyState.flag('city_exit_unlocked'), isTrue);
    var mushroom = fsm.startConversation('forest_mushroom');
    expect(mushroom.responses.map((r) => r.id), contains('collect_ink'));
    mushroom = choose(mushroom, 'collect_ink');
    expect(mushroom.id, 'mushroom_collected');
    expect(state.hasItem('empty_bottle'), isFalse);
    expect(state.quantity('ink_bottle'), 1);
    expect(state.status('navigator_ink'), QuestStatus.ready);
    choose(mushroom, 'leave');
    final waiting = fsm.startConversation('old_sailor');
    choose(waiting, 'give_ink');
    expect(state.status('navigator_ink'), QuestStatus.completed);
    expect(state.hasItem('ink_bottle'), isFalse);
    expect(state.quantity('tartu_route_map'), 1);
    expect(state.completeQuest('navigator_ink'), isFalse);
    expect(state.quantity('tartu_route_map'), 1);
  });

  test('missing bottle gives a useful return-to-town option, not free ink', () {
    acceptQuest();
    final mushroom = fsm.startConversation('forest_mushroom');
    expect(mushroom.responses.map((r) => r.id), isNot(contains('collect_ink')));
    expect(choose(mushroom, 'need_bottle').id, 'mushroom_need_bottle');
    expect(fsm.storyState.adventure.hasItem('ink_bottle'), isFalse);
  });

  test('poisoning emits retry event and leaves all quest progress intact', () {
    acceptQuest();
    final state = fsm.storyState.adventure;
    state.collectPickup('empty_bottle_pickup');
    final before = Map.of(state.inventory);
    final mushroom = fsm.startConversation('forest_mushroom');
    final death = fsm.chooseResponse(
        mushroom, mushroom.responses.indexWhere((r) => r.id == 'lick_goo'));
    expect(death.response.event, 'mushroom_poisoning');
    fsm.endConversation();
    // The retry rebuilds a VIEW, not StoryState or the whole playthrough.
    expect(state.inventory, before);
    expect(state.status('navigator_ink'), QuestStatus.active);
    final retry = fsm.startConversation('forest_mushroom');
    expect(retry.responses.map((r) => r.id), contains('collect_ink'));
    choose(retry, 'collect_ink');
    expect(state.quantity('ink_bottle'), 1);
  });

  test('ink cannot be recollected via another actor or stale reply', () {
    acceptQuest();
    fsm.storyState.adventure.collectPickup('empty_bottle_pickup');
    final node = fsm.startConversation('inkcap');
    final index = node.responses.indexWhere((r) => r.id == 'collect_ink');
    final selected = fsm.chooseResponse(node, index);
    expect(selected.response.effects.last['award_score']['id'],
        'collect_forest_ink');
    expect(() => fsm.chooseResponse(node, index), throwsStateError);
    fsm.endConversation();
    expect(fsm.startConversation('forest_mushroom').id, 'mushroom_collected');
    expect(fsm.storyState.adventure.quantity('ink_bottle'), 1);
  });

  test('inventory delivery also awards exactly one map', () {
    acceptQuest();
    final state = fsm.storyState.adventure;
    state.addItem('ink_bottle');
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNotNull);
    expect(state.quantity('tartu_route_map'), 1);
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNull);
    expect(state.quantity('tartu_route_map'), 1);
  });

  test(
      'guard unlocks only connected travel and scenarios reference existing assets',
      () {
    for (final from in QuestLocations.paths.keys) {
      for (final to in QuestLocations.paths.keys) {
        expect(
            QuestLocations.canTravel(from, to, gateUnlocked: false), isFalse);
      }
      final raw =
          jsonDecode(File(QuestLocations.paths[from]!).readAsStringSync())
              as Map<String, dynamic>;
      final scene = ScenarioConfig.fromJson(raw);
      expect(scene.id, from);
      for (final entity in scene.entities) {
        if (entity.dialogueActorId != null)
          expect(graph['actors'], contains(entity.dialogueActorId));
        if (entity.destination != null) {
          expect(
              QuestLocations.canTravel(from, entity.destination!,
                  gateUnlocked: true),
              isTrue);
        }
        if (entity.assetId.startsWith('resources/'))
          expect(File(entity.assetId).existsSync(), isTrue);
      }
    }
    expect(
        QuestLocations.canTravel(QuestLocations.town, QuestLocations.forest,
            gateUnlocked: true),
        isFalse);
    expect(
        QuestLocations.canTravel(QuestLocations.town, QuestLocations.river,
            gateUnlocked: true),
        isFalse);
    expect(
        QuestLocations.canTravel(QuestLocations.town, QuestLocations.gates,
            gateUnlocked: true),
        isTrue);
    expect(
        QuestLocations.canTravel(QuestLocations.gates, QuestLocations.river,
            gateUnlocked: true),
        isTrue);
    expect(
        QuestLocations.canTravel(QuestLocations.forest, QuestLocations.river,
            gateUnlocked: true),
        isTrue);
  });

  test('guard requires the lady directions and passage requests the gates VIEW',
      () {
    acceptQuest();
    expect(fsm.startConversation('city_guard').id, 'guard_idle');
    fsm.endConversation();
    choose(
        choose(fsm.startConversation('female_clothes_trader'), 'explain_ink'),
        'thank_lady');
    final guard = fsm.startConversation('city_guard');
    expect(guard.id, 'guard_forest');
    final passage = fsm.chooseResponse(
        guard, guard.responses.indexWhere((r) => r.id == 'follow_directions'));
    expect(passage.response.event, 'guard_passage');
    expect(fsm.storyState.flag('city_exit_unlocked'), isTrue);
    expect(graph['actors'].containsKey('sleeping_drunk'), isFalse);
  });

  test('new game clears route access, pickups, ink and map', () {
    acceptQuest();
    choose(
        choose(fsm.startConversation('female_clothes_trader'), 'explain_ink'),
        'thank_lady');
    choose(fsm.startConversation('city_guard'), 'follow_directions');
    fsm.storyState.adventure.collectPickup('empty_bottle_pickup');
    choose(fsm.startConversation('forest_mushroom'), 'collect_ink');
    fsm.storyState.adventure.completeQuest('navigator_ink');
    fsm.resetProgress();
    expect(fsm.storyState.flag('city_exit_unlocked'), isFalse);
    expect(fsm.storyState.adventure.inventory, {'task_scroll': 1});
    expect(fsm.canStartConversation('female_clothes_trader'), isFalse);
    expect(
        fsm.storyState.adventure.collectPickup('empty_bottle_pickup'), isTrue);
  });
}
