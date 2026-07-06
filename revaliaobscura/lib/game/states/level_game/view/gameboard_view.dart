import 'dart:async';

import 'package:revalia/game/states/level_game/model/player_model.dart';
import 'package:revalia/game/states/level_game/view/dialog_frame_entity.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/game/states/level_game/view/playerentity.dart';
import 'package:revalia/game/states/level_game/view/sailor_npc_entity.dart';
import 'package:revalia/game/states/level_game/view/walking_area_entity.dart';
import 'package:revalia/revalia_obs.dart';

import 'package:revalia/game/states/level_game/model/gameboardmodel.dart';
import 'package:revalia/game/states/level_game/view/game_board_ui_comp_handler.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/ui/game_text_component.dart';
import 'package:flame/components.dart';

class GameboardView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late GameBoardModel gBoardModel;
  int horizontalCells = 0;
  int verticalCells = 0;
  late List<LevelEntity> levelEntities;
  late WalkingAreaEntity walkingAreaView;
  late PlayerPosEntity playerEntity;

  late int activeLevel = gBoardModel.currentLevel;
  late UIGameBoardComponents uiGameBoardComponents;

  bool isBoardLoaded = false;
  bool isGameFinished = false;
  bool isGameStarted = false;
  bool isEnemyDefeated = false;
  int clickCount = 0;

  DialogFrameEntity? df;

  ActionableType actionType = ActionableType.move;
  int _conclusionToken = 0;

  late LevelEntity activeActor;
  GameboardView() {
    gBoardModel = GameBoardModel();
    uiGameBoardComponents = UIGameBoardComponents(gameboardView: this);
  }
  @override
  void onLoad() {
    super.onLoad();
    print("GameboardView onLoad");
    isBoardLoaded = false;
    levelEntities = <LevelEntity>[];
    uiGameBoardComponents.gameRef = gameRef;
  }

  @override
  void onMount() {
    super.onMount();
    // debugMode = true;
    print("GameboardView onMount");

    //clearBoard();

    uiGameBoardComponents.loadUIComponents(gameRef);

    addWalkingArea();
    addPlayer();
    addNPC();

    isBoardLoaded = true;
    isGameFinished = false;
    clickCount = 0;
    gameRef.ap.stopMusic();
    gameRef.ap.playMusic(Assets.resources.audio.mfxcitygates, loop: true);
    //game generic button uses an internal await that fucked me over
    uiGameBoardComponents.gameActionGroup
        .onButtonTapped(uiGameBoardComponents.wallkButton);
  }

  void clearBoard() {
    if (levelEntities.isEmpty) {
      return;
    }
    for (final entity in levelEntities) {
      entity.animationHandler.cleanUpAnimations();

      if (entity.parent != null) {
        print("entity.parent.toString() ${entity.parent.toString()}");
        remove(entity);
      }
    }
    levelEntities.clear();
  }

  @override
  void onRemove() {
    super.onRemove();
    _conclusionToken++;
    gameRef.cam.moveTo(Vector2(0, 0));
    uiGameBoardComponents.removeGameUIComponents();

    isGameFinished = true;
    isGameStarted = false;
    clickCount = 0;
    removeAll(children);
    levelEntities.clear();
    df = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
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
    return !isGameFinished && gameRef.gboard.gBoardModel.levelPlayTime <= 0;
  }

  void handleLevelConclusion(bool isWin) {
    isBoardLoaded = false;
    isGameFinished = true;
    isGameStarted = false;
    clickCount = 0;

    gameRef.gboard.onLevelConclusion(isWin);
  }

  void updateCameraMovement() {
    if (clickCount == 0) {
      gameRef.cam.moveTo(Vector2(playerEntity.x - 100, playerEntity.y - 100));
    } else if (clickCount == 1) {
      gameRef.cam.moveTo(Vector2(playerEntity.x - 100, playerEntity.y - 100));
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
    gameRef.gameFsm.gameScore();
  }

  void onLevelConclusion(bool win) {
    final token = ++_conclusionToken;
    if (win) {
      gBoardModel.flipResultOutcome = ActionOutcome.levelCompleted;
      gameRef.ap.playSoundFx(Assets.resources.audio.levelup);

      gameRef.ap.stopMusic();
      gameRef.ap.playMusic(Assets.resources.audio.mfxLevelWin);
    } else {
      gBoardModel.flipResultOutcome = gBoardModel.levelPlayTime <= 0
          ? ActionOutcome.timeOver
          : ActionOutcome.invalidMove;
      gameRef.ap.playSoundFx(Assets.resources.audio.explosion2);

      gameRef.ap.stopMusic();
      gameRef.ap.playMusic(Assets.resources.audio.mfxGameOver);
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

  void addPlayer() {
    PlayerModel playerModel =
        PlayerModel(x: 0, y: 0, status: PlayerModel.WALKING);
    playerEntity = PlayerPosEntity(
        playerModel: playerModel,
        position: Vector2(160, 200),
        size: Vector2(50, 84));

    add(playerEntity);
  }

  void addWalkingArea() {
    walkingAreaView = WalkingAreaEntity(
      position: Vector2(160, 200),
      size: Vector2(200, 32),
    );
    levelEntities.add(walkingAreaView);
    add(walkingAreaView);
  }

  void addNPC() {
    final npc = SailorNpcEntity(
      position: Vector2(25, 150),
      size: Vector2(50, 85),
    );
    levelEntities.add(npc);
    add(npc);
  }

  Vector2 constrainToWalkingArea(Vector2 requestedPosition) {
    final halfWidth = walkingAreaView.size.x / 2;
    final minX = walkingAreaView.position.x - halfWidth;
    final maxX = walkingAreaView.position.x + halfWidth;
    return Vector2(
      requestedPosition.x.clamp(minX, maxX).toDouble(),
      walkingAreaView.position.y,
    );
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
        gameRef.currentLocale, "dialogues.$dialogId.player_text");
    // If df exists, remove it first
    if (df == null) {
      df = DialogFrameEntity(
          position: Vector2(160, 80), size: Vector2(256 + 16, 32 + 16));
      add(df!);
      df?.showScreenMessage(message);
    } else if (!df!.isDialogActive) {
      add(df!);
      df?.showScreenMessage(message);
    } else {
      print("dialog already active");
    }
  }

  void removeDialogFrame() {
    df?.clearDialogText();
    df?.removeFromParent();
  }
}
