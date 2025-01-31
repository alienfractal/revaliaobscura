import 'dart:async';

import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/game/states/game/model/gameboardmodel.dart';
import 'package:coolorburn/utils/ui/text_component.dart';
import 'package:coolorburn/gen/assets.gen.dart';
import 'package:coolorburn/utils/text_utils.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum ScoreViewType { levelWon, gameover }

class GameScoreView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late SpriteComponent gameBackground;
  late BlinkingTextComponent textComponentLoading;
  late BlinkingTextComponent textComponentItemsUsed;
  late BlinkingTextComponent textComponentTimeUsed;
  late BlinkingTextComponent textComponentCurrentScore;
  late BlinkingTextComponent textComponentCoinsCollected;
  late ScoreViewType viewType;

  // Fields for centralized model data
  late int energyCount;
  late int levelPlayTime;
  late int coinCount;
  late int totalScore;
  late ActionOutcome flipResultOutcome;

  @override
  void onLoad() {
    super.onLoad();
    viewType = ScoreViewType.levelWon;
    init();
  }

  @override
  void onMount() {
    print("Score onMount");
    super.onMount();
    initializeModelData(); // Centralized model initialization
    scoreSummary();
  }

  @override
  void onRemove() {
    super.onRemove();
    textComponentCurrentScore.disableBlinking();
    gameBackground.removeFromParent();
    textComponentLoading.removeFromParent();
    textComponentItemsUsed.removeFromParent();
    textComponentTimeUsed.removeFromParent();
    textComponentCurrentScore.removeFromParent();
    textComponentCoinsCollected.removeFromParent();
  }

  // Initialization of components
  void init() {
    gameBackground = gameRef.actorCacheService.gameBackground;

    textComponentLoading = TextUtils.addTextToview(
        gameRef,
        'SCORE SUMMARY',
        Vector2(90, 10),
        16,
        true,
        Colors.white,
        1.0,
        false);

    textComponentItemsUsed = TextUtils.addTextToview(
        gameRef,
        'Energy left: ${0}',
        Vector2(10, 75),
        6,
        true,
        TextUtils.coolblueText,
        1.0,
        false);

    textComponentTimeUsed = TextUtils.addTextToview(
        gameRef,
        'Time left: ${0}',
        Vector2(10, 100),
        6,
        true,
        TextUtils.coolblueText,
        1.0,
        false);

    textComponentCoinsCollected = TextUtils.addTextToview(
        gameRef,
        'Coins Collected: ${0}',
        Vector2(10, 125),
        6,
        true,
        TextUtils.yellowText,
        1.0,
        false);

    textComponentCurrentScore = TextUtils.addTextToview(
        gameRef,
        'Total Score: ${0}',
        Vector2(10, 150),
        6,
        true,
        TextUtils.yellowText,
        1.0,
        false);

    textComponentCurrentScore.toggleBlinking();

    addAll([
      gameBackground,
      textComponentLoading,
      textComponentItemsUsed,
      textComponentTimeUsed,
      textComponentCurrentScore,
      textComponentCoinsCollected
    ]);
  }

  // Centralized initialization of model data
  void initializeModelData() {
    energyCount = gameRef.gboard.gBoardModel.energyCount;
    levelPlayTime = gameRef.gboard.gBoardModel.levelPlayTime.round();
    coinCount = gameRef.gboard.gBoardModel.coinCount;
    totalScore = gameRef.gboard.gBoardModel.totalScore;
    flipResultOutcome = gameRef.gboard.gBoardModel.flipResultOutcome;
  }

  void scoreSummary() {
    animateFlameTimeScoreCount();
    Future.delayed(const Duration(milliseconds: 3500), () {
      transitionToNextState();
    });
  }

  Future<void> animateFlameTimeScoreCount() async {
    for (int i = 0; i <= min(energyCount, 4); i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      textComponentItemsUsed.text = 'Energy left: $i';
      gameRef.ap.playSoundFx(Assets.resources.audio.pickupCoin);
    }
    textComponentItemsUsed.text = 'Energy left: $energyCount';

    var round = min(levelPlayTime, 4);
    for (int i = 0; i <= round; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      textComponentTimeUsed.text = 'Time left: $i';
      gameRef.ap.playSoundFx(Assets.resources.audio.pickupCoin);
    }
    textComponentTimeUsed.text = 'Time left: $round';

    if (coinCount > 0) {
      for (int i = 0; i <= min(coinCount, 4); i++) {
        await Future.delayed(const Duration(milliseconds: 120));
        textComponentCoinsCollected.text = 'Coins Collected: $i';
        gameRef.ap.playSoundFx(Assets.resources.audio.pickupCoin);
      }
    }
    textComponentCoinsCollected.text = 'Coins Collected: $coinCount';

    int oldScore = totalScore;
    gameRef.gboard.gBoardModel.calculateScore();
    totalScore = gameRef.gboard.gBoardModel.totalScore;
    for (int i = oldScore; i <= totalScore; i++) {
      textComponentCurrentScore.text = 'Total Score: $i';
    }
  }

  @override
  void transitionToNextState() {
    print('ScoreView lastOutcome = $flipResultOutcome');
    switch (flipResultOutcome) {
      case ActionOutcome.invalidMove  :
        gameRef.gameFsm.gameEnd();
        break;
      case ActionOutcome.timeOver:
        gameRef.gameFsm.gameEnd();
        break;
      case ActionOutcome.levelCompleted:
        gameRef.gameFsm.gameLoading();
        break;
      default:
    }
  }
}
