import 'dart:async';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:revalia/dialoguefsm/adventure_state.dart';
import 'package:revalia/game/states/level_game/scenario/quest_locations.dart';
import 'package:revalia/game/states/level_game/view/quest_scene_entity.dart';

import 'package:revalia/game/states/level_game/model/player_model.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_loader.dart';
import 'package:revalia/game/states/level_game/view/animated_scene_prop_entity.dart';
import 'package:revalia/game/states/level_game/view/clothes_trader_npc_entity.dart';
import 'package:revalia/game/states/level_game/view/dialog_frame_entity.dart';
import 'package:revalia/game/states/level_game/view/female_clothes_trader_npc_entity.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/game/states/level_game/view/inventory_popup.dart';
import 'package:revalia/game/states/level_game/view/market_background_entity.dart';
import 'package:revalia/game/states/level_game/view/perspective_guide_entity.dart';
import 'package:revalia/game/states/level_game/view/playerentity.dart';
import 'package:revalia/game/states/level_game/view/sailor_npc_entity.dart';
import 'package:revalia/game/states/level_game/view/static_scene_prop_entity.dart';
import 'package:revalia/game/states/level_game/view/walking_area_entity.dart';
import 'package:revalia/revalia_obs.dart';

import 'package:revalia/game/states/level_game/model/gameboardmodel.dart';
import 'package:revalia/game/states/level_game/view/game_board_ui_comp_handler.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/dialogsystem/dialog_event_manager.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/ui/game_text_component.dart';
import 'package:flame/components.dart';

class GameboardView extends World
    with HasGameReference<RevaliaObs>
    implements ViewTransitionInterface {
  final String locationId;
  final String? arrivedFrom;
  bool _travelRequested = false;
  bool _poisoning = false;
  bool _retryPoisoningRequested = false;
  double _poisonSeconds = 0;
  int? _scorePopupPoints;
  String? _pendingLocation;
  String? _dialogueTravelDestination;
  late GameBoardModel gBoardModel;
  int horizontalCells = 0;
  int verticalCells = 0;
  late List<LevelEntity> levelEntities;
  late WalkingAreaEntity walkingAreaView;
  late PlayerPosEntity playerEntity;
  late ScenarioConfig scenario;

  late int activeLevel = gBoardModel.currentLevel;
  late UIGameBoardComponents uiGameBoardComponents;

  bool isBoardLoaded = false;
  bool isGameFinished = false;
  bool isGameStarted = false;
  bool isEnemyDefeated = false;
  int clickCount = 0;
  bool _scoreTransitionRequested = false;

  DialogFrameEntity? df;
  SpriteComponent? _observationImage;
  InventoryPopup? _inventoryPopup;
  String? selectedInventoryItem;
  bool get isInventoryOpen => _inventoryPopup != null;

  String adventureText(String key) =>
      AppTranslations.translationsFor(game.currentLocale)[key] ?? key;

  void toggleInventory() {
    if (isInventoryOpen) {
      closeInventory();
    } else if (isBoardLoaded &&
        !isGameFinished &&
        !(df?.isDialogActive ?? false)) {
      playerEntity.cancelMovement();
      _inventoryPopup = InventoryPopup(this);
      game.cam.viewport.add(_inventoryPopup!);
    }
  }

  void closeInventory() {
    _inventoryPopup?.removeFromParent();
    _inventoryPopup = null;
  }

  void selectInventoryItem(String itemId) {
    selectedInventoryItem = itemId;
    actionType = ActionableType.touch;
    uiGameBoardComponents.gameActionGroup
        .onButtonTapped(uiGameBoardComponents.touchButton);
    closeInventory();
    showScreenMessage(adventureText('inventory.use_hint'));
  }

  bool useInventoryItemOn(LevelEntity target) {
    final item = selectedInventoryItem;
    if (item == null) return false;
    selectedInventoryItem = null;
    if (item == 'empty_bottle' && target.interactionId == 'inkcap') {
      return handleQuestAction(target, ActionableType.touch);
    }
    final quest = DialogueManager.fsm.storyState.adventure
        .deliverItem(item, target.interactionId);
    if (quest != null) _awardQuestCompletion();
    if (quest == null) selectedInventoryItem = item;
    showScreenMessage(quest == null
        ? adventureText('inventory.cannot_use')
        : adventureText('quests.${quest.id}.completed'));
    return true;
  }

  ActionableType actionType = ActionableType.move;
  int _conclusionToken = 0;
  late final DialogueEventListener _dialogueEventListener;

  late LevelEntity activeActor;
  GameboardView(
      {GameBoardModel? model,
      this.locationId = QuestLocations.town,
      this.arrivedFrom}) {
    gBoardModel = model ?? GameBoardModel();
    uiGameBoardComponents = UIGameBoardComponents(gameboardView: this);
    _dialogueEventListener = _handleDialogueEvent;
  }
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print("GameboardView onLoad");
    isBoardLoaded = false;
    levelEntities = <LevelEntity>[];
    uiGameBoardComponents.gameRef = game;
    scenario = await ScenarioLoader.load(
      QuestLocations.paths[locationId]!,
    );
    final foregroundPath = scenario.foregroundAssetPath;
    if (foregroundPath != null) {
      final sprite = await game.loadSprite(foregroundPath);
      add(SpriteComponent(
        sprite: sprite,
        size: sprite.srcSize.clone(),
        position: Vector2(
          (game.camDimension.x - sprite.srcSize.x) / 2,
          game.camDimension.y - sprite.srcSize.y,
        ),
        // Above all depth-sorted actors; below observations and dialogue.
        // No tap handlers: the scenery does not intercept world interactions.
        priority: 1000,
      ));
    }
  }

  @override
  void onMount() {
    super.onMount();
    DialogEventManager.addListener(_dialogueEventListener);
    actionType = ActionableType.move;
    // debugMode = true;
    print("GameboardView onMount");

    //clearBoard();

    _buildScenario(scenario);
    uiGameBoardComponents.loadUIComponents(game);

    isBoardLoaded = true;
    isGameFinished = false;
    _scoreTransitionRequested = false;
    clickCount = 0;
    game.ap.playMusic(Assets.resources.audio.mfxcitygates, loop: true);
    //game generic button uses an internal await that fucked me over
    uiGameBoardComponents.gameActionGroup
        .onButtonTapped(uiGameBoardComponents.wallkButton);
  }

  void clearBoard() {
    if (levelEntities.isEmpty) {
      return;
    }
    for (final entity in levelEntities) {
      if (entity.parent != null) {
        print("entity.parent.toString() ${entity.parent.toString()}");
        entity.removeFromParent();
      }
    }
    levelEntities.clear();
  }

  @override
  void onRemove() {
    DialogEventManager.removeListener(_dialogueEventListener);
    closeInventory();
    selectedInventoryItem = null;
    super.onRemove();
    _conclusionToken++;
    game.cam.moveTo(Vector2(0, 0));
    uiGameBoardComponents.removeGameUIComponents();

    isGameFinished = true;
    isGameStarted = false;
    _scoreTransitionRequested = false;
    clickCount = 0;
    levelEntities.clear();
    df = null;
    _observationImage = null;
  }

  void _handleDialogueEvent(String event) {
    if (event == 'guard_passage') {
      _dialogueTravelDestination = QuestLocations.gates;
      return;
    }
    if (event == 'mushroom_poisoning') {
      // Defer until the response handler has closed the dialogue frame.
      _poisoning = true;
      _poisonSeconds = 0;
      return;
    }
    if (event == 'conversation_end' &&
        DialogueManager.fsm.storyState.adventure.status('navigator_ink') ==
            QuestStatus.completed) {
      _awardQuestCompletion();
    }
    if (event.startsWith('score_milestone:')) {
      final parts = event.split(':');
      if (parts.length == 3) {
        final points = int.tryParse(parts[2]);
        if (points != null &&
            gBoardModel.awardScoreMilestone(parts[1], points)) {
          game.ap.playSoundFx(Assets.resources.audio.blipSelect2);
          updateUIComponents();
          uiGameBoardComponents.flashScoreChange();
          _scorePopupPoints = points;
        }
      }
      return;
    }
    if (event == 'choose_response:laugh' ||
        event == 'choose_response:laugh_again') {
      playerEntity.playerAnimationHandler.showLaugh();
      return;
    }
    if (event != 'player_death') {
      return;
    }
    final deathMessageKey = activeActor.interactionId == 'knife_mushroom'
        ? 'knife_mushroom_killed'
        : 'player_killed';
    isGameFinished = true;
    playerEntity.disableActions();
    activeActor.requestAttack(
      onComplete: () {
        game.ap.playSoundFx(Assets.resources.audio.blockHit2);
        playerEntity.playerAnimationHandler.triggerDie(
          onComplete: () => _finishPlayerDeath(deathMessageKey),
        );
      },
    );
  }

  void _finishPlayerDeath(String messageKey) {
    if (!isMounted) {
      return;
    }
    gBoardModel.flipResultOutcome = ActionOutcome.playerKilled;
    DialogueManager.setTranslations(
      AppTranslations.translationsFor(game.currentLocale),
    );
    showScreenMessage(
      DialogueManager.message(messageKey),
      durationSeconds: null,
      onDismissed: () {
        if (isMounted) {
          _scoreTransitionRequested = true;
        }
      },
    );
  }

  @override
  void updateTree(double dt) {
    if (!isInventoryOpen) super.updateTree(dt);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dialogueTravelDestination != null && !(df?.isDialogActive ?? false)) {
      final destination = _dialogueTravelDestination!;
      _dialogueTravelDestination = null;
      travelTo(destination);
    }
    if (_pendingLocation != null) {
      final next = _pendingLocation!;
      _pendingLocation = null;
      game.openLocation(next, arrivedFrom: locationId);
      return;
    }
    if (_retryPoisoningRequested) {
      _retryPoisoningRequested = false;
      game.openLocation(QuestLocations.forest);
      return;
    }
    if (_scorePopupPoints != null) {
      final points = _scorePopupPoints!;
      _scorePopupPoints = null;
      final popup = TextComponent(
          text: '+$points',
          position: Vector2(40, 30),
          priority: 3000,
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontFamily: 'scumm',
                  fontSize: 12,
                  color: Color(0xffffdb69))));
      add(popup);
      popup.add(TimerComponent(
          period: 2, removeOnFinish: true, onTick: popup.removeFromParent));
    }
    if (_poisoning) {
      _updatePoisoning(dt);
      return;
    }
    if (_scoreTransitionRequested) {
      _scoreTransitionRequested = false;
      game.cam.stop();
      game.cam.viewfinder.position = Vector2.zero();
      game.gameFsm.gameScore();
      return;
    }
    updateUI(dt);
  }

  void updateUI(double dt) {
    if (!isBoardLoaded) {
      return;
    }

    if (isGameFinished) {
      return;
    }

    if (!isGameStarted) {
      print("focusCameraOnStartTile");
      focusCameraOnStartTile();
      return;
    }

    if (isGameTimeOver()) {
      print("isGameTimeOver");
      handleLevelConclusion(false);
      return;
    } else if (isEnergyDepleted()) {
      print("isEnergyDepleted");
      handleLevelConclusion(false);
      return;
    } else if (isEnemyDefeated) {
      print("isEnemyDefeated");
      handleLevelConclusion(true);
      return;
    }

    //updateCameraMovement();
    updateGameStats(dt);
    updateUIComponents();
  }

  void focusCameraOnStartTile() {
    print("levelEntities.length ${levelEntities.length}");

    isGameStarted = true;
  }

  bool isGameTimeOver() {
    return !isGameFinished && game.gboard.gBoardModel.levelPlayTime <= 0;
  }

  void handleLevelConclusion(bool isWin) {
    isBoardLoaded = false;
    isGameFinished = true;
    isGameStarted = false;
    clickCount = 0;

    game.gboard.onLevelConclusion(isWin);
  }

  void updateCameraMovement() {
    if (clickCount == 0) {
      game.cam.moveTo(Vector2(playerEntity.x - 100, playerEntity.y - 100));
    } else if (clickCount == 1) {
      game.cam.moveTo(Vector2(playerEntity.x - 100, playerEntity.y - 100));
    }
  }

  void updateGameStats(double dt) {
    // The quest demo allows time to explore and read dialogue.
  }

  void updateUIComponents() {
    // Update score
    uiGameBoardComponents.blinkTextComponentScore.text =
        " X ${gBoardModel.totalScore.toString().padLeft(4, '0')} ";

    // Update energy bar
    uiGameBoardComponents.energyBar
        .updateEnergy(gBoardModel.energyCount.toDouble());

    // Update timer and status
    updateTimerUI();
  }

  void updateTimerUI() {
    String timeText =
        gBoardModel.levelPlayTime.toInt().toString().padLeft(3, '0');
    uiGameBoardComponents.textComponentTime.textComponent.text =
        " TIME :$timeText ";

    if (gBoardModel.levelPlayTime.toInt() >= 30) {
      uiGameBoardComponents.textComponentTime
          .updateUI(GameTextComponent.NORMAL);
    } else if (gBoardModel.levelPlayTime.toInt() >= 5) {
      uiGameBoardComponents.textComponentTime
          .updateUI(GameTextComponent.WARNING);
    } else {
      int status = (gBoardModel.levelPlayTime * 8).toInt() % 3;
      uiGameBoardComponents.textComponentTime.updateUI(status);
    }
  }

  @override
  void transitionToNextState() {
    game.gameFsm.gameScore();
  }

  void onLevelConclusion(bool win) {
    final token = ++_conclusionToken;
    if (win) {
      gBoardModel.flipResultOutcome = ActionOutcome.levelCompleted;
      game.ap.playSoundFx(Assets.resources.audio.levelup);

      game.ap.playMusic(Assets.resources.audio.mfxLevelWin);
    } else {
      gBoardModel.flipResultOutcome = gBoardModel.levelPlayTime <= 0
          ? ActionOutcome.timeOver
          : ActionOutcome.invalidMove;
      game.ap.playSoundFx(Assets.resources.audio.explosion2);

      game.ap.playMusic(Assets.resources.audio.mfxGameOver);
    }

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!isMounted || token != _conclusionToken) {
        return;
      }
      transitionToNextState();
    });
  }

  bool isEnergyDepleted() {
    return !isGameFinished && gBoardModel.energyCount <= 0;
  }

  void _buildScenario(ScenarioConfig scenario) {
    PerspectiveConfig.configure(
      horizonY: scenario.perspective.horizonY,
      nearestWalkableHorizonY: scenario.perspective.minimumWalkableY,
      minimumCharacterScale: scenario.perspective.minimumScale,
      maximumCharacterScale: scenario.perspective.maximumScale,
    );
    addBackground(scenario.backgroundId);
    if (scenario.showPerspectiveGuide) {
      addPerspectiveGuide();
    }
    addWalkingArea(
      scenario.walkingAreaVertices,
      showGuide: scenario.showPerspectiveGuide,
    );
    final arrival = scenario.arrivals[arrivedFrom];
    addPlayer(arrival == null
        ? scenario.player
        : ScenarioPlayerConfig(
            feetPosition: arrival, size: scenario.player.size));
    for (final entity in scenario.entities) {
      addScenarioEntity(entity);
    }
  }

  void addPlayer(ScenarioPlayerConfig config) {
    PlayerModel playerModel =
        PlayerModel(x: 0, y: 0, status: PlayerModel.WALKING);
    playerEntity = PlayerPosEntity(
      playerModel: playerModel,
      position: config.feetPosition,
      size: config.size,
    );

    add(playerEntity);
  }

  void addBackground(String backgroundId) {
    add(
      MarketBackgroundEntity(
        position: Vector2(160, 100),
        size: Vector2(320, 200),
        backgroundId: backgroundId,
      ),
    );
  }

  void addPerspectiveGuide() {
    add(PerspectiveGuideEntity());
  }

  void addWalkingArea(List<Vector2> vertices, {bool showGuide = false}) {
    walkingAreaView = WalkingAreaEntity(
      vertices: vertices,
      showGuide: showGuide,
    );
    levelEntities.add(walkingAreaView);
    add(walkingAreaView);
  }

  void addScenarioEntity(ScenarioEntityConfig config) {
    if (DialogueManager.fsm.storyState.adventure
        .wasCollected(config.interactionId)) return;
    final LevelEntity entity;
    switch (config.type) {
      case 'npc':
        switch (config.assetId) {
          case 'old_sailor':
            if (config.dialogueActorId == null) {
              throw ArgumentError(
                'The old sailor needs a dialogue actor ID.',
              );
            }
            entity = SailorNpcEntity(
              feetPosition: config.feetPosition,
              size: config.size,
              interactionId: config.interactionId,
              dialogueActorId: config.dialogueActorId!,
              isWalkable: config.isWalkable,
              scalesWithPerspective: config.scalesWithPerspective,
              sortsWithDepth: config.sortsWithDepth,
            );
          case 'clothes_trader':
            entity = ClothesTraderNpcEntity(
              feetPosition: config.feetPosition,
              size: config.size,
              interactionId: config.interactionId,
              isWalkable: config.isWalkable,
              scalesWithPerspective: config.scalesWithPerspective,
              sortsWithDepth: config.sortsWithDepth,
            );
          case 'female_clothes_trader':
            entity = FemaleClothesTraderNpcEntity(
              dialogueActorId: config.dialogueActorId,
              feetPosition: config.feetPosition,
              size: config.size,
              interactionId: config.interactionId,
              isWalkable: config.isWalkable,
              scalesWithPerspective: config.scalesWithPerspective,
              sortsWithDepth: config.sortsWithDepth,
            );
          default:
            throw ArgumentError(
              'Unsupported NPC configuration: ${config.assetId}',
            );
        }
      case 'quest_prop':
      case 'decoration':
      case 'exit':
        entity = QuestSceneEntity(config);
      case 'static_prop':
        entity = StaticScenePropEntity(
          assetPath: config.assetId,
          interactionId: config.interactionId,
          feetPosition: config.feetPosition,
          visualSize: config.size,
          isWalkable: config.isWalkable,
          scalesWithPerspective: config.scalesWithPerspective,
          sortsWithDepth: config.sortsWithDepth,
        );
      case 'animated_prop':
        entity = AnimatedScenePropEntity(
          interactionId: config.interactionId,
          feetPosition: config.feetPosition,
          visualSize: config.size,
          idleAnimation: _propAnimation(config.assetId),
          isWalkable: config.isWalkable,
          scalesWithPerspective: config.scalesWithPerspective,
          sortsWithDepth: config.sortsWithDepth,
        );
      default:
        throw ArgumentError.value(
          config.type,
          'type',
          'Unsupported scenario entity type',
        );
    }
    levelEntities.add(entity);
    add(entity);
  }

  SpriteAnimation _propAnimation(String assetId) {
    switch (assetId) {
      case 'glowing_gem':
        return game.entitySpriteCache.glowingGem.animation;
      default:
        throw ArgumentError.value(
          assetId,
          'assetId',
          'Unknown animated prop asset ID',
        );
    }
  }

  Vector2 constrainToWalkingArea(Vector2 requestedPosition) {
    return walkingAreaView.constrainWorldPoint(requestedPosition);
  }

  Vector2 interactionDestinationFor(LevelEntity actor) {
    return constrainToWalkingArea(actor.interactionPoint);
  }

  void travelTo(String destination) {
    if (_travelRequested || isGameFinished || (df?.isDialogActive ?? false))
      return;
    if (!QuestLocations.canTravel(locationId, destination,
        gateUnlocked:
            DialogueManager.fsm.storyState.flag('city_exit_unlocked'))) {
      showScreenMessage(adventureText('messages.city_exit_locked.text'));
      return;
    }
    _travelRequested = true;
    playerEntity.cancelMovement();
    playerEntity.disableActions();
    closeInventory();
    selectedInventoryItem = null;
    _pendingLocation = destination;
  }

  bool handleQuestAction(LevelEntity target, ActionableType action) {
    if (target.interactionId == 'inkcap' && action == ActionableType.touch) {
      final collected = DialogueManager.fsm.storyState.collectForestInk();
      if (collected) {
        _handleDialogueEvent('score_milestone:collect_forest_ink:250');
      }
      showScreenMessage(adventureText(collected
          ? 'messages.inkcap_collected.text'
          : 'messages.inkcap_already_collected.text'));
      return true;
    }
    if (target.interactionId == 'metsavana' && action == ActionableType.talk) {
      showScreenMessage(adventureText('messages.metsavana_silent.text'));
      return true;
    }
    return false;
  }

  void _awardQuestCompletion() {
    _handleDialogueEvent('score_milestone:deliver_hendrik_ink:500');
  }

  void _updatePoisoning(double dt) {
    if (_poisonSeconds == 0) {
      removeDialogFrame();
      isGameFinished = true;
      playerEntity.cancelMovement();
      playerEntity.disableActions();
      playerEntity.playerAnimationHandler.spriteAnimationComponent.paint
              .colorFilter =
          const ColorFilter.mode(Color(0xff59bb45), BlendMode.modulate);
      game.ap.playSoundFx(Assets.resources.audio.death);
    }
    _poisonSeconds += dt;
    if (_poisonSeconds < 1.0) return;
    _poisoning = false;
    playerEntity.playerAnimationHandler.triggerDie(onComplete: () {
      if (!isMounted) return;
      showScreenMessage(adventureText('messages.mushroom_poisoned.text'),
          durationSeconds: null, onDismissed: () {
        if (isMounted) _retryPoisoningRequested = true;
      });
    });
  }

  void callRenderDialogue(LevelEntity actorEntity) {
    activeActor = actorEntity;
    // If df exists, remove it first
    if (df == null) {
      df = DialogFrameEntity(
          position: Vector2(160, 80), size: Vector2(256 + 16, 32 + 16));
      add(df!);
      df?.initDialog(activeActor.dialogueActorId!);
    } else if (!df!.isDialogActive) {
      add(df!);
      df?.initDialog(activeActor.dialogueActorId!);
    } else {
      print("dialog already active");
    }
  }

  void callRenderDialogueOnError(String dialogId) {
    final message = AppTranslations.getTranslation(
        game.currentLocale, "dialogues.$dialogId.player_text");
    showScreenMessage(message);
  }

  void showScreenMessage(
    String message, {
    double? durationSeconds = 15,
    void Function()? onDismissed,
  }) {
    _showScreenMessageAt(
      message,
      position: Vector2(160, 80),
      durationSeconds: durationSeconds,
      onDismissed: onDismissed,
    );
  }

  void showObservation({
    required SpriteComponent image,
    required String message,
  }) {
    if (df?.isDialogActive ?? false) {
      return;
    }

    _removeObservationImage();
    image
      ..anchor = Anchor.topLeft
      ..position = Vector2(96, 32)
      ..priority = 1999;
    _observationImage = image;
    add(image);

    _showScreenMessageAt(
      message,
      position: Vector2(160, 152),
      onDismissed: _removeObservationImage,
    );
  }

  void _showScreenMessageAt(
    String message, {
    required Vector2 position,
    double? durationSeconds = 15,
    void Function()? onDismissed,
  }) {
    // If df exists, remove it first
    if (df == null) {
      df = DialogFrameEntity(
        position: position,
        size: Vector2(256 + 16, 32 + 16),
      );
      add(df!);
      df?.showScreenMessage(
        message,
        durationSeconds: durationSeconds,
        onDismissed: onDismissed,
      );
    } else if (!df!.isDialogActive) {
      df!.position = position;
      add(df!);
      df?.showScreenMessage(
        message,
        durationSeconds: durationSeconds,
        onDismissed: onDismissed,
      );
    } else {
      print("dialog already active");
    }
  }

  void _removeObservationImage() {
    _observationImage?.removeFromParent();
    _observationImage = null;
  }

  void removeDialogFrame() {
    _removeObservationImage();
    df?.clearDialogText();
    df?.removeFromParent();
  }
}
