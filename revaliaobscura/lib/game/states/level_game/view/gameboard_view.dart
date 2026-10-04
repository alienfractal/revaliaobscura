import 'dart:async';

import 'package:revalia/game/states/level_game/model/player_model.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_loader.dart';
import 'package:revalia/game/states/level_game/view/animated_scene_prop_entity.dart';
import 'package:revalia/game/states/level_game/view/dialog_frame_entity.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/game/states/level_game/view/market_background_entity.dart';
import 'package:revalia/game/states/level_game/view/perspective_guide_entity.dart';
import 'package:revalia/game/states/level_game/view/playerentity.dart';
import 'package:revalia/game/states/level_game/view/sailor_npc_entity.dart';
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

  ActionableType actionType = ActionableType.move;
  int _conclusionToken = 0;
  late final DialogueEventListener _dialogueEventListener;

  late LevelEntity activeActor;
  GameboardView({GameBoardModel? model}) {
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
      'resources/scenarios/town_square.json',
    );
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
  }

  void _handleDialogueEvent(String event) {
    if (event.startsWith('score_milestone:')) {
      final parts = event.split(':');
      if (parts.length == 3) {
        final points = int.tryParse(parts[2]);
        if (points != null &&
            gBoardModel.awardScoreMilestone(parts[1], points)) {
          game.ap.playSoundFx(Assets.resources.audio.blipSelect2);
          updateUIComponents();
          uiGameBoardComponents.flashScoreChange();
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
    isGameFinished = true;
    playerEntity.disableActions();
    activeActor.requestAttack(
      onComplete: () {
        game.ap.playSoundFx(Assets.resources.audio.blockHit2);
        playerEntity.playerAnimationHandler.triggerDie(
          onComplete: _finishPlayerDeath,
        );
      },
    );
  }

  void _finishPlayerDeath() {
    if (!isMounted) {
      return;
    }
    gBoardModel.flipResultOutcome = ActionOutcome.playerKilled;
    DialogueManager.setTranslations(
      AppTranslations.translationsFor(game.currentLocale),
    );
    showScreenMessage(
      DialogueManager.message('player_killed'),
      durationSeconds: null,
      onDismissed: () {
        if (isMounted) {
          _scoreTransitionRequested = true;
        }
      },
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
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
    if (clickCount > 2) {
      gBoardModel.levelPlayTime -= dt;
    }
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
    addWalkingArea(scenario.walkingAreaVertices);
    addPlayer(scenario.player);
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

  void addWalkingArea(List<Vector2> vertices) {
    walkingAreaView = WalkingAreaEntity(vertices: vertices);
    levelEntities.add(walkingAreaView);
    add(walkingAreaView);
  }

  void addScenarioEntity(ScenarioEntityConfig config) {
    final LevelEntity entity;
    switch (config.type) {
      case 'npc':
        if (config.assetId != 'old_sailor' || config.dialogueActorId == null) {
          throw ArgumentError(
            'Unsupported NPC configuration: ${config.assetId}',
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
    // If df exists, remove it first
    if (df == null) {
      df = DialogFrameEntity(
          position: Vector2(160, 80), size: Vector2(256 + 16, 32 + 16));
      add(df!);
      df?.showScreenMessage(
        message,
        durationSeconds: durationSeconds,
        onDismissed: onDismissed,
      );
    } else if (!df!.isDialogActive) {
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

  void removeDialogFrame() {
    df?.clearDialogText();
    df?.removeFromParent();
  }
}
