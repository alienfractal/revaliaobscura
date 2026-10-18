from pathlib import Path
S=Path(__file__).resolve().parent/'.forest-mushrooms-work'
p=S/'test/ink_quest_flow_test.dart'
t=p.read_text(encoding='utf-8')
t=t.replace("expect(mushroom.responses.map((r) => r.id), contains('collect_ink'));\n    mushroom = choose(mushroom, 'collect_ink');\n    expect(mushroom.id, 'mushroom_collected');", "expect(mushroom.responses.map((r) => r.id), contains('ask_ink'));\n    mushroom = choose(mushroom, 'ask_ink');\n    expect(mushroom.id, 'wise_mushroom_ink');\n    expect(fsm.storyState.collectForestInk(), isTrue);")
start=t.index("  test('missing bottle")
end=t.index("  test('inventory delivery",start)
t=t[:start]+'''  test('touching purple mushroom supplies ink without a bottle or dialogue', () {
    expect(fsm.storyState.adventure.hasItem('empty_bottle'), isFalse);
    expect(fsm.storyState.collectForestInk(), isTrue);
    expect(fsm.storyState.adventure.quantity('ink_bottle'), 1);
    expect(fsm.activeSession, isNull);
    acceptQuest();
    expect(fsm.storyState.adventure.status('navigator_ink'), QuestStatus.ready);
  });

  test('knife mushroom yes emits fatal death; no is safe', () {
    var knife = fsm.startConversation('knife_mushroom');
    final yes = fsm.chooseResponse(knife, knife.responses.indexWhere((r) => r.id == 'yes'));
    expect(yes.response.event, 'player_death');
    expect(yes.next, 'end');
    fsm.endConversation();
    knife = fsm.startConversation('knife_mushroom');
    final no = fsm.chooseResponse(knife, knife.responses.indexWhere((r) => r.id == 'no'));
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
    expect(fsm.startConversation('forest_mushroom').id, 'wise_mushroom_after_ink');
    expect(state.deliverItem('ink_bottle', 'old_sailor'), isNotNull);
    expect(fsm.storyState.collectForestInk(), isFalse);
    expect(state.hasItem('ink_bottle'), isFalse);
  });

'''+t[end:]
t=t.replace("choose(fsm.startConversation('forest_mushroom'), 'collect_ink');","fsm.storyState.collectForestInk();")
p.write_text(t,encoding='utf-8')

p=S/'test/quest_views_test.dart'
t=p.read_text(encoding='utf-8')
t=t.replace("import 'package:revalia/revalia_obs.dart';", "import 'package:revalia/revalia_obs.dart';\nimport 'package:revalia/gamefsm/fsm.dart';\nimport 'package:revalia/gamefsm/game_fsm.dart';\nimport 'package:revalia/game/states/level_game/model/gameboardmodel.dart';")
where=t.index('class _QuestGame')
t=t[:where]+'''class _DeathRecordingFsm extends GameFsm {
  _DeathRecordingFsm(RevaliaObs game) : super(currentState: Fsm.gstart, mainGame: game);
  int scoreTransitions = 0;
  @override
  void gameScore() { scoreTransitions++; }
}

'''+t[where:]
t=t.replace("ap = _SilentAudio();", "ap = _SilentAudio();\n    gameFsm = _DeathRecordingFsm(this);")
t=t.replace("'VIEW travel, poison retry and return preserve the bottle and score'", "'VIEW travel, three animated mushrooms, touch ink and delivery'")
start=t.index('    final mushroom = game.gboard.levelEntities')
end=t.index('    game.gboard.travelTo(QuestLocations.river);', start)
t=t[:start]+'''    final mushroom = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'forest_mushroom');
    final purple = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'inkcap');
    final knife = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'knife_mushroom');
    expect(mushroom.animationHandler.idleAnimation.frames.length, 19);
    expect(mushroom.animationHandler.talkAnimation!.frames.length, 19);
    expect(purple.animationHandler.idleAnimation.frames.length, 10);
    expect(knife.animationHandler.idleAnimation.frames.length, 9);
    expect(knife.animationHandler.attackAnimation!.frames.length, 9);
    expect(knife.animationHandler.attackAnimation!.loop, isFalse);
    game.gboard.callRenderDialogue(mushroom);
    await tester.pump();
    final wise = DialogueManager.fsm.dialogues['wise_mushroom_intro']!;
    expect(wise.responses.map((r) => r.id), contains('ask_ink'));
    game.gboard.df!.loadDialogueTextToFrame('end');
    await _settle(tester, game);
    purple.performAction(ActionableType.touch);
    await tester.pump();
    expect(DialogueManager.fsm.activeSession, isNull);
    expect(game.gboard.gBoardModel.totalScore, 350);
    expect(state.quantity('ink_bottle'), 1);
    expect(state.hasItem('empty_bottle'), isFalse);
    expect(game.gboard.playerEntity.playerModel.isAlive, isTrue);
    purple.performAction(ActionableType.touch);
    await tester.pump();
    expect(state.quantity('ink_bottle'), 1);
    expect(game.gboard.gBoardModel.totalScore, 350);
    await _capture(tester, 'forest-ink-collected');
    await tester.tapAt(const Offset(320, 160));
    await _settle(tester, game);
'''+t[end:]
# A separate widget test follows the actual attack ticker and player death.
last=t.rfind('\n}')
t=t[:last]+'''
  testWidgets('knife mushroom plays attack, kills player and requests game over', (tester) async {
    final game = _QuestGame();
    await tester.runAsync(() async {
      game.onGameResize(Vector2(640, 400));
      await game.load();
    });
    await tester.pumpWidget(MaterialApp(home: Align(alignment: Alignment.topLeft,
      child: RepaintBoundary(key: const Key('quest-preview'),
        child: SizedBox(width:640,height:400,child:GameWidget(game:game))))));
    await _settle(tester,game);
    DialogueManager.fsm.storyState.applyEffects([{'set_flag':'city_exit_unlocked'}]);
    for (final location in [QuestLocations.gates,QuestLocations.river,QuestLocations.forest]) {
      game.gboard.travelTo(location);
      await tester.pump(const Duration(milliseconds:16));
      await _settle(tester,game);
    }
    final knife=game.gboard.levelEntities.firstWhere((e)=>e.interactionId=='knife_mushroom');
    game.gboard.callRenderDialogue(knife);
    await tester.pump();
    var node=DialogueManager.fsm.dialogues['knife_mushroom_intro']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(node,
      node.responses.indexWhere((r)=>r.id=='no')));
    game.gboard.df!.loadDialogueTextToFrame('end');
    await _settle(tester,game);
    expect(game.gboard.isGameFinished,isFalse);
    expect(game.gboard.playerEntity.playerModel.isAlive,isTrue);
    game.gboard.callRenderDialogue(knife);
    await tester.pump();
    node=DialogueManager.fsm.dialogues['knife_mushroom_intro']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(node,
      node.responses.indexWhere((r)=>r.id=='yes')));
    await tester.pump(const Duration(milliseconds:16));
    expect(knife.animationHandler.isAnimating,isTrue);
    expect(game.gboard.isGameFinished,isTrue);
    for(var i=0;i<50;i++) { await tester.pump(const Duration(milliseconds:100)); }
    expect(game.gboard.playerEntity.playerModel.isAlive,isFalse);
    expect(game.gboard.gBoardModel.flipResultOutcome,ActionOutcome.playerKilled);
    expect(DialogueManager.fsm.storyState.adventure.hasItem('ink_bottle'),isFalse);
    await _capture(tester,'knife-mushroom-death');
    await tester.tapAt(const Offset(320,160));
    await tester.pump(const Duration(milliseconds:100));
    expect((game.gameFsm as _DeathRecordingFsm).scoreTransitions,1);
    expect(game.gboard.scenario.id,QuestLocations.forest);
    expect(game.gboard.playerEntity.playerModel.isAlive,isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(),isNull);
  });
'''+t[last:]
p.write_text(t,encoding='utf-8')
print('Updated quest-flow and mounted-view tests for the three forest mushrooms.')
