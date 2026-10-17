from pathlib import Path

STAGE=Path(__file__).resolve().parent
def edit(path,old,new):
    p=STAGE/path
    t=p.read_text(encoding='utf-8')
    assert old in t,(path,old[:60])
    p.write_text(t.replace(old,new),encoding='utf-8')

p='test/ink_quest_flow_test.dart'
edit(p, "QuestLocations.town, QuestLocations.river,\n            gateUnlocked: true),\n        isTrue);", "QuestLocations.town, QuestLocations.river,\n            gateUnlocked: true),\n        isFalse);\n    expect(QuestLocations.canTravel(QuestLocations.town, QuestLocations.gates, gateUnlocked: true), isTrue);\n    expect(QuestLocations.canTravel(QuestLocations.gates, QuestLocations.river, gateUnlocked: true), isTrue);")
edit(p,"    choose(fsm.startConversation('city_guard'), 'follow_directions');", "    choose(choose(fsm.startConversation('female_clothes_trader'), 'explain_ink'), 'thank_lady');\n    choose(fsm.startConversation('city_guard'), 'follow_directions');")
edit(p,"  test('new game clears route access, pickups, ink and map', () {", '''  test('guard requires the lady directions and passage requests the gates VIEW', () {
    acceptQuest();
    expect(fsm.startConversation('city_guard').id, 'guard_idle');
    fsm.endConversation();
    choose(choose(fsm.startConversation('female_clothes_trader'), 'explain_ink'), 'thank_lady');
    final guard = fsm.startConversation('city_guard');
    expect(guard.id, 'guard_forest');
    final passage = fsm.chooseResponse(guard, guard.responses.indexWhere((r) => r.id == 'follow_directions'));
    expect(passage.response.event, 'guard_passage');
    expect(fsm.storyState.flag('city_exit_unlocked'), isTrue);
    expect(graph['actors'].containsKey('sleeping_drunk'), isFalse);
  });

  test('new game clears route access, pickups, ink and map', () {''')

p='test/quest_views_test.dart'
edit(p,"import 'package:revalia/revalia_obs.dart';", "import 'package:revalia/revalia_obs.dart';\nimport 'package:revalia/utils/components/actionable_entitty_component.dart';")
edit(p,"      {'set_flag': 'city_exit_unlocked'},\n",'')
edit(p,'''    state.collectPickup('empty_bottle_pickup');
    game.gboard.gBoardModel.awardScoreMilestone('test_existing', 100);
    game.gboard.travelTo(QuestLocations.river);''', '''    expect(state.hasItem('empty_bottle'), isFalse);
    expect(game.gboard.levelEntities.where((e) => e.interactionId == 'sleeping_drunk'), isEmpty);
    final lady = game.gboard.levelEntities.firstWhere((e) => e.interactionId == 'female_clothes_trader');
    game.gboard.callRenderDialogue(lady);
    await tester.pump();
    var node = DialogueManager.fsm.dialogues['lady_hendrik']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(node,
      node.responses.indexWhere((r) => r.id == 'explain_ink')));
    node = DialogueManager.fsm.dialogues['lady_directions']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(node,0));
    await _settle(tester,game);
    final guard = game.gboard.levelEntities.firstWhere((e) => e.interactionId == 'city_guard');
    game.gboard.callRenderDialogue(guard);
    await tester.pump();
    node = DialogueManager.fsm.dialogues['guard_forest']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(node,
      node.responses.indexWhere((r) => r.id == 'follow_directions')));
    await tester.pump(const Duration(milliseconds:16));
    await _settle(tester,game);
    expect(game.gboard.scenario.id,QuestLocations.gates);
    expect(state.hasItem('empty_bottle'),isFalse);
    await _capture(tester,'gates');
    final count = game.gboard.levelEntities.firstWhere((e) => e.interactionId == 'sleeping_drunk');
    final expectedSequence = [1,1,1,2,3,5,6,7,5,6,7,5,6,7,1,2,3,4,5,2,2,2,2,1,2,3,4,5,6,7];
    expect(count.animationHandler.idleAnimation.frames.map((f) => (f.sprite.srcPosition.x / 32).round() + 1), expectedSequence);
    count.performAction(ActionableType.talk);
    await tester.pump();
    expect(DialogueManager.fsm.activeSession,isNull);
    expect(game.gboard.df!.isDialogActive,isTrue);
    await tester.tapAt(const Offset(320,160));
    await _settle(tester,game);
    final bottle = game.gboard.levelEntities.firstWhere((e) => e.interactionId == 'empty_bottle_pickup');
    bottle.performAction(ActionableType.touch);
    await tester.pump();
    expect(state.hasItem('empty_bottle'),isTrue);
    await tester.tapAt(const Offset(320,160));
    await _settle(tester,game);
    game.gboard.gBoardModel.awardScoreMilestone('test_existing', 100);
    game.gboard.travelTo(QuestLocations.river);''')
edit(p,'''    game.gboard.travelTo(QuestLocations.town);
    await tester.pump(const Duration(milliseconds: 16));''', '''    game.gboard.travelTo(QuestLocations.gates);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester,game);
    expect(game.gboard.scenario.id,QuestLocations.gates);
    expect(game.gboard.levelEntities.where((e) => e.interactionId == 'empty_bottle_pickup'),isEmpty);
    game.gboard.travelTo(QuestLocations.town);
    await tester.pump(const Duration(milliseconds: 16));''')
print('Updated connected-route and mounted VIEW checks.')
