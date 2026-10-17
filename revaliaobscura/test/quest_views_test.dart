import 'dart:io';
import 'dart:ui' as ui;
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/sound/web_audio_player.dart';
import 'package:revalia/game/states/level_game/scenario/quest_locations.dart';

class _SilentAudio extends WebAudioPlayer {
  @override
  void playSoundFx(String path) {}
  @override
  Future<void> playMusic(String path,
      {bool loop = false, int playCount = 1}) async {}
}

class _QuestGame extends RevaliaObs {
  @override
  Future<void> onLoad() async {
    ap = _SilentAudio();
    Flame.images.prefix = '';
    await entitySpriteCache.preloadAnimations(this);
    await entitySpriteCache.preloadSprites(this);
    await uiSpriteCache.preloadAnimations(this);
    await uiSpriteCache.preloadSprites(this);
    await playerSpriteCache.preloadAnimations(this);
    await appTranslations.loadTranslations();
    await DialogueManager.loadDialogueGraph(
        assetPath: 'resources/dialogues/revalia_dialogues.json',
        translations: {});
    DialogueManager.fsm.storyState.applyEffects([
      {'set_flag': 'navigator_ink_quest_started'},
      {'start_quest': 'navigator_ink'},
    ]);
    viewport = FixedResolutionViewport(resolution: camDimension);
    cam = camera;
    cam.viewport = viewport;
    cam.viewfinder.anchor = Anchor.topLeft;
    switchToWorld(gboard);
  }
}

Future<void> _settle(WidgetTester tester, _QuestGame game) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
  }
  expect(tester.takeException(), isNull);
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('quest-preview')));
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/quest-previews').createSync(recursive: true);
    File('build/quest-previews/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    for (final entry in {
      'scumm': 'SCUMM-Font.ttf',
      'press2p': 'PressStart2P-Regular.ttf'
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load('resources/fonts/${entry.value}'));
      await loader.load();
    }
  });
  testWidgets(
      'VIEW travel, poison retry and return preserve the bottle and score',
      (tester) async {
    final game = _QuestGame();
    await tester.runAsync(() async {
      game.onGameResize(Vector2(640, 400));
      await game.load();
    });
    await tester.pumpWidget(MaterialApp(
        home: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
                key: const Key('quest-preview'),
                child: SizedBox(
                    width: 640, height: 400, child: GameWidget(game: game))))));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.town);
    await _capture(tester, 'town');
    final state = DialogueManager.fsm.storyState.adventure;
    expect(state.hasItem('empty_bottle'), isFalse);
    expect(
        game.gboard.levelEntities
            .where((e) => e.interactionId == 'sleeping_drunk'),
        isEmpty);
    final lady = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'female_clothes_trader');
    game.gboard.callRenderDialogue(lady);
    await tester.pump();
    var node = DialogueManager.fsm.dialogues['lady_hendrik']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(
        node, node.responses.indexWhere((r) => r.id == 'explain_ink')));
    node = DialogueManager.fsm.dialogues['lady_directions']!;
    game.gboard.df!
        .loadDialogueTextToFrame(DialogueManager.chooseResponse(node, 0));
    await _settle(tester, game);
    final guard = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'city_guard');
    game.gboard.callRenderDialogue(guard);
    await tester.pump();
    node = DialogueManager.fsm.dialogues['guard_forest']!;
    game.gboard.df!.loadDialogueTextToFrame(DialogueManager.chooseResponse(
        node, node.responses.indexWhere((r) => r.id == 'follow_directions')));
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.gates);
    expect(state.hasItem('empty_bottle'), isFalse);
    await _capture(tester, 'gates');
    final count = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'sleeping_drunk');
    final expectedSequence = [
      1,
      1,
      1,
      2,
      3,
      5,
      6,
      7,
      5,
      6,
      7,
      5,
      6,
      7,
      1,
      2,
      3,
      4,
      5,
      2,
      2,
      2,
      2,
      1,
      2,
      3,
      4,
      5,
      6,
      7
    ];
    expect(
        count.animationHandler.idleAnimation.frames
            .map((f) => (f.sprite.srcPosition.x / 32).round() + 1),
        expectedSequence);
    count.performAction(ActionableType.talk);
    await tester.pump();
    expect(DialogueManager.fsm.activeSession, isNull);
    expect(game.gboard.df!.isDialogActive, isTrue);
    await tester.tapAt(const Offset(320, 160));
    await _settle(tester, game);
    final bottle = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'empty_bottle_pickup');
    bottle.performAction(ActionableType.touch);
    await tester.pump();
    expect(state.hasItem('empty_bottle'), isTrue);
    await tester.tapAt(const Offset(320, 160));
    await _settle(tester, game);
    game.gboard.gBoardModel.awardScoreMilestone('test_existing', 100);
    game.gboard.travelTo(QuestLocations.river);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.river);
    expect(state.hasItem('empty_bottle'), isTrue);
    await _capture(tester, 'river');
    game.gboard.travelTo(QuestLocations.forest);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.forest);
    final walkingGnome = game.gboard.levelEntities
        .firstWhere((entity) => entity.interactionId == 'walking_gnome');
    expect(walkingGnome.children.whereType<Behavior>(), isEmpty);
    expect(walkingGnome.animationHandler.idleAnimation.frames.length, 5);
    final gnomeStartX = walkingGnome.x;
    for (var tick = 0; tick < 10; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(walkingGnome.x, greaterThan(gnomeStartX));
    final walkingGnomeY = walkingGnome.y;
    walkingGnome.position.x = 335;
    walkingGnome.update(0.2);
    expect(walkingGnome.x, closeTo(-14.6, 0.001));
    expect(walkingGnome.y, walkingGnomeY);
    expect(walkingGnome.priority, lessThan(1000));
    walkingGnome.x = gnomeStartX + 12;
    final foreground = game.gboard.children.whereType<SpriteComponent>()
        .singleWhere((component) => component.priority == 1000);
    expect(foreground.size.x, 320);
    expect(foreground.size, foreground.sprite!.srcSize);
    expect(foreground.position.x, 0);
    expect(foreground.position.y + foreground.size.y, 200);
    expect(foreground.priority, greaterThan(game.gboard.playerEntity.priority));
    expect(game.gboard.scenario.backgroundId,
        'resources/images/forest-background-320x200-1.png');
    await _capture(tester, 'forest');
    final mushroom = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'forest_mushroom');
    game.gboard.callRenderDialogue(mushroom);
    await tester.pump();
    final dialogue = DialogueManager.fsm.dialogues['mushroom_ink']!;
    final next = DialogueManager.chooseResponse(
        dialogue, dialogue.responses.indexWhere((r) => r.id == 'lick_goo'));
    game.gboard.df!.loadDialogueTextToFrame(next);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(game.gboard.isGameFinished, isTrue);
    expect(game.gboard.playerEntity.playerModel.isAlive, isFalse);
    expect(state.hasItem('empty_bottle'), isTrue);
    await _capture(tester, 'poison');
    // Dismissing the death message retries this location without a new game.
    await tester.tapAt(const Offset(320, 160));
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.forest);
    expect(game.gboard.playerEntity.playerModel.isAlive, isTrue);
    expect(game.gboard.gBoardModel.totalScore, 100);
    expect(state.hasItem('empty_bottle'), isTrue);
    final retryMushroom = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'forest_mushroom');
    game.gboard.callRenderDialogue(retryMushroom);
    await tester.pump();
    final collectNode = DialogueManager.fsm.dialogues['mushroom_ink']!;
    final collected = DialogueManager.chooseResponse(collectNode,
        collectNode.responses.indexWhere((r) => r.id == 'collect_ink'));
    game.gboard.df!.loadDialogueTextToFrame(collected);
    final done = DialogueManager.fsm.dialogues['mushroom_collected']!;
    game.gboard.df!
        .loadDialogueTextToFrame(DialogueManager.chooseResponse(done, 0));
    await tester.pump(const Duration(seconds: 2));
    expect(game.gboard.gBoardModel.totalScore, 350);
    expect(state.hasItem('ink_bottle'), isTrue);
    expect(state.hasItem('empty_bottle'), isFalse);
    game.gboard.travelTo(QuestLocations.river);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    game.gboard.travelTo(QuestLocations.gates);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.gates);
    expect(
        game.gboard.levelEntities
            .where((e) => e.interactionId == 'empty_bottle_pickup'),
        isEmpty);
    game.gboard.travelTo(QuestLocations.town);
    await tester.pump(const Duration(milliseconds: 16));
    await _settle(tester, game);
    expect(game.gboard.scenario.id, QuestLocations.town);
    expect(
        game.gboard.levelEntities
            .where((e) => e.interactionId == 'empty_bottle_pickup'),
        isEmpty);
    final sailor = game.gboard.levelEntities
        .firstWhere((e) => e.interactionId == 'old_sailor');
    game.gboard.callRenderDialogue(sailor);
    await tester.pump();
    final waiting = DialogueManager.fsm.dialogues['npc_waiting_for_ink']!;
    final thanks = DialogueManager.chooseResponse(
        waiting, waiting.responses.indexWhere((r) => r.id == 'give_ink'));
    game.gboard.df!.loadDialogueTextToFrame(thanks);
    final thankNode = DialogueManager.fsm.dialogues[thanks]!;
    game.gboard.df!
        .loadDialogueTextToFrame(DialogueManager.chooseResponse(thankNode, 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(state.quantity('tartu_route_map'), 1);
    expect(state.hasItem('ink_bottle'), isFalse);
    expect(game.gboard.gBoardModel.totalScore, 850);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
