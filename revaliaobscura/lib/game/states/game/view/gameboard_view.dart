import 'dart:async';

import 'package:coolorburn/game/states/game/model/player_model.dart';
import 'package:coolorburn/game/states/game/view/playerview.dart';
import 'package:coolorburn/revalia_obs.dart';

import 'package:coolorburn/game/states/game/model/gameboardmodel.dart';
import 'package:coolorburn/game/states/game/model/actor_model.dart';
import 'package:coolorburn/game/states/game/view/cardview.dart';
import 'package:coolorburn/game/states/game/view/game_board_ui_component.dart';
import 'package:coolorburn/gen/assets.gen.dart';
import 'package:coolorburn/utils/color_status_text_component.dart';
import 'package:flame/components.dart';

class GameboardView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late GameBoardModel gBoardModel;
  int horizontalCells = 0;
  int verticalCells = 0;
  late List<ActorView> actors;
  late ActorView actorView;
  late PlayerView playerView;

  late int activeLevel = gBoardModel.currentLevel;
  late UIGameBoardComponents uiGameBoardComponents;

  bool isBoardLoaded = false;
  bool isGameFinished = false;
  bool isGameStarted = false;
  bool isEnemyDefeated = false;
  int clickCount = 0;

  double _emplasedTime = -1;

  GameboardView() {
    gBoardModel = GameBoardModel();
    uiGameBoardComponents = UIGameBoardComponents(gameboardView: this);
  }
  @override
  void onLoad() {
    super.onLoad();
    print("GameboardView onLoad");
    isBoardLoaded = false;
    actors = <ActorView>[]; // Initialize the list of cards
    uiGameBoardComponents.gameRef = gameRef;
  
  }

  @override
  void onMount() {
     super.onMount();
    print("GameboardView onMount");

    //clearBoard();
    
    uiGameBoardComponents.loadUIComponents(gameRef);
   // addActor();
    addPlayer();
    
    isBoardLoaded = true;
    isGameFinished = false;
    clickCount = 0;
    gameRef.ap.stopMusic();
    gameRef.ap.playMusic(Assets.resources.audio.mfxFear);
 
   
  }

  void clearBoard() {
    if (actors.isEmpty) {
      return;
    }
    for (ActorView card in actors) {
      card.animationHandler.cleanUpAnimations();

      if (card.parent != null) {
        print("card.parent.toString() ${card.parent.toString()}");
        remove(card);
      }
    }
    actors.clear();

  
  }

  @override
  void onRemove() {
    super.onRemove();
    gameRef.cam.moveTo(Vector2(0, 0));
    uiGameBoardComponents.removeGameUIComponents();

    isGameFinished = true;
    isGameStarted = false;
    clickCount = 0;

  }

  @override
  void update(double dt) {
    super.update(dt);
    updateUI(dt);
 
  }

 

  void updateUI(double dt) {
  if (!isBoardLoaded) {return;}

  if(isGameFinished){
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
  }
  else if(isEnergyDepleted()){
    print("isEnergyDepleted");
    handleLevelConclusion(false);
    return;
  }
  else if(isEnemyDefeated){
    print("isEnemyDefeated");
    handleLevelConclusion(true);
    return;
  }

  updateCameraMovement();
  updateGameStats(dt);
  updateUIComponents();
}

void focusCameraOnStartTile() {
  print("actors.length ${actors.length} ${actors.toString()}  ");
  //ActorView actorViewStart = actors
  //    .firstWhere((actor) => actor.actorModel.status == ActorModel.PLAYER);
 //print("actorViewStart ${actorViewStart.toString()} ${actorViewStart.actorModel.toString()} ");

  Vector2 cardViewPosition = playerView.position - Vector2(150, 100);
  gameRef.cam.moveTo(cardViewPosition, speed: 100.0);

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
    gameRef.cam.moveTo(Vector2(playerView.x - 100, playerView.y - 100));
  } else if (clickCount == 1) {
    gameRef.cam.moveTo(Vector2(playerView.x - 100, playerView.y - 100));

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
  uiGameBoardComponents.energyBar.updateEnergy(gBoardModel.energyCount.toDouble());

  // Update timer and status
  updateTimerUI();
}

void updateTimerUI() {
  String timeText = gBoardModel.levelPlayTime.toInt().toString().padLeft(3, '0');
  uiGameBoardComponents.textComponentTime.text = " TIME :$timeText ";

  if (gBoardModel.levelPlayTime.toInt() >= 30) {
    uiGameBoardComponents.textComponentTime.updateUI(ColorStatusTextComponent.NORMAL);
  } else if (gBoardModel.levelPlayTime.toInt() >= 5) {
    uiGameBoardComponents.textComponentTime.updateUI(ColorStatusTextComponent.WARNING);
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
  
    if (win) {
      gBoardModel.flipResultOutcome = ActionOutcome.timeOver;
      gameRef.ap.playSoundFx(Assets.resources.audio.levelup);

      gameRef.ap.stopMusic();
      gameRef.ap.playMusic(  Assets.resources.audio.mfxLevelWin);
      
    } else {
      gBoardModel.flipResultOutcome = ActionOutcome.timeOver;
      gameRef.ap.playSoundFx(Assets.resources.audio.explosion2);
     
      gameRef.ap.stopMusic();
      gameRef.ap.playMusic(  Assets.resources.audio.mfxGameOver);
      
    }

    Future.delayed(const Duration(milliseconds: 3500), () {
   
      transitionToNextState();
    });
  }
  
  bool isEnergyDepleted() { 
    return !isGameFinished && gBoardModel.energyCount <= 0;
  }
  

  
  void addActor() { 

    ActorModel graveModel = ActorModel(x: 0, y: 0, distance: 0, status:  ActorModel.RELIC, prev: null);
    actorView = ActorView(actorModel: graveModel, position:Vector2(0, 0));
    actors.add(actorView);
    add(actorView);
  }

    void addPlayer() { 

    PlayerModel playerModel = PlayerModel(x: 0, y: 0, status:  PlayerModel.WALKING);
    playerView = PlayerView(playerModel: playerModel, position:Vector2(32, 64));
    
    add(playerView);
  }
}
