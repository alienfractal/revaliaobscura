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
    expect(mushroom.responses.map((r) => r.id), contains('ask_ink'));
    mushroom = choose(mushroom, 'ask_ink');
    expect(mushroom.id, 'wise_mushroom_ink');
    expect(fsm.storyState.collectForestInk(), isTrue);
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

  test('touching purple mushroom supplies ink without a bottle or dialogue',
      () {
    expect(fsm.storyState.adventure.hasItem('empty_bottle'), isFalse);
    expect(fsm.storyState.collectForestInk(), isTrue);
    expect(fsm.storyState.adventure.quantity('ink_bottle'), 1);
    expect(fsm.activeSession, isNull);
    acceptQuest();
    expect(fsm.storyState.adventure.status('navigator_ink'), QuestStatus.ready);
  });

  test('knife mushroom yes emits fatal death; no is safe', () {
    var knife = fsm.startConversation('knife_mushroom');
    final yes = fsm.chooseResponse(
        knife, knife.responses.indexWhere((r) => r.id == 'yes'));
    expect(yes.response.event, 'player_death');
    expect(yes.next, 'end');
    fsm.endConversation();
    knife = fsm.startConversation('knife_mushroom');
    final no = fsm.chooseResponse(
        knife, knife.responses.indexWhere((r) => r.id == 'no'));
    expect(no.response.event, isNull);
    expect(no.next, 'knife_mushroom_relief');
  });

  test('wise mushroom explains the forest but cannot award ink', () {
    acceptQuest();
    var wise = fsm.startConversation('forest_mushroom');
    expect(wise.responses.map((r) => r.id), isNot(contains('collect_ink')));
    wise = choose(wise, 'ask_metsavana');
    expect(wise.id, 'wise_mushroom_metsavana');
    wise = choose(wise, 'ask_gnomes');
    expect(wise.id, 'wise_mushroom_gnomes');
    expect(fsm.storyState.adventure.hasItem('ink_bottle'), isFalse);
  });

  test('ink cannot be recollected after delivery or through conversation', () {
    acceptQuest();
    final state = fsm.storyState.adventure;
    state.collectPickup('empty_bottle_pickup');
    expect(fsm.storyState.collectForestInk(), isTrue);
    expect(state.hasItem('empty_bottle'), isFalse);
    expect(fsm.storyState.collectForestInk(), isFalse);
    expect(state.quantity('ink_bottle'), 1);
    expect(
        fsm.startConversation('forest_mushroom').id, 'wise_mushroom_after_ink');
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNotNull);
    expect(fsm.storyState.collectForestInk(), isFalse);
    expect(state.hasItem('ink_bottle'), isFalse);
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
        if (entity.dialogueActorId != null) {
          expect(graph['actors'], contains(entity.dialogueActorId));
        }
        if (entity.destination != null) {
          expect(
              QuestLocations.canTravel(from, entity.destination!,
                  gateUnlocked: true),
              isTrue);
        }
        if (entity.assetId.startsWith('resources/')) {
          expect(File(entity.assetId).existsSync(), isTrue);
        }
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
    fsm.storyState.collectForestInk();
    fsm.storyState.adventure.completeQuest('navigator_ink');
    fsm.resetProgress();
    expect(fsm.storyState.flag('city_exit_unlocked'), isFalse);
    expect(fsm.storyState.adventure.inventory, {'task_scroll': 1});
    expect(fsm.canStartConversation('female_clothes_trader'), isFalse);
    expect(
        fsm.storyState.adventure.collectPickup('empty_bottle_pickup'), isTrue);
  });
}
