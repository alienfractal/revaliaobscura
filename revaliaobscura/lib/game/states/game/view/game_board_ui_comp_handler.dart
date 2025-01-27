import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/game/states/game/behaviours/arrow_button_bevaviour.dart';
import 'package:coolorburn/game/states/game/model/gameboardmodel.dart';
import 'package:coolorburn/game/states/game/view/gameboard_view.dart';
import 'package:coolorburn/game/states/main_menu/behaviours/music_button_taphandler.dart';
import 'package:coolorburn/game/states/main_menu/behaviours/sound_button_taphandler.dart';
import 'package:coolorburn/gen/assets.gen.dart';
 
import 'package:coolorburn/utils/game_button.dart';
import 'package:coolorburn/utils/game_energy_bar.dart';
import 'package:coolorburn/utils/game_generic_button.dart';
import 'package:coolorburn/utils/game_generic_sprite.dart';
 

import 'package:coolorburn/utils/color_status_text_component.dart';
import 'package:coolorburn/utils/text_component.dart';
import 'package:coolorburn/utils/text_utils.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class UIGameBoardComponents {
  late RevaliaObs gameRef;
  late GameBoardModel gBoardModel;

  late GameboardView gameboardView;

  late BlinkingTextComponent blinkTextComponentScore;
  late ColorStatusTextComponent textComponentTime;
  late BlinkingTextComponent blinkTextComponentEnergy;

  late GenericButton touchButton;
  late GenericButton talkButton;
  late GenericButton lookButton;
  late GenericButton wallkButton;
  late GenericButton flameIcon;
  late GenericButton timeIcon;
  late GenericButton bombIcon;
  late GenericSpriteAnimation scoreIcon;
  late EnergyBar energyBar;

  late GameButton buttonSndFXVolume;

  late GameButton buttonMscFXVolume;

  UIGameBoardComponents({required this.gameboardView}) {
    gBoardModel = gameboardView.gBoardModel;
  }

  void removeGameUIComponents() {
    // Add the game UI components here
    touchButton.removeFromParent();
    talkButton.removeFromParent();
    lookButton.removeFromParent();
    wallkButton.removeFromParent();
    timeIcon.removeFromParent();
    scoreIcon.removeFromParent();
    energyBar.removeFromParent();
    blinkTextComponentScore.removeFromParent();
    textComponentTime.removeFromParent();
    buttonSndFXVolume.removeFromParent();
    buttonMscFXVolume.removeFromParent();
  }

  void loadUIComponents(RevaliaObs gameRef) {
    gameboardView.add(gameRef.enemyCacheService.oldTownCenter);

    blinkTextComponentScore = TextUtils.addTextToview(
        gameRef,
        'SCORE : ${gBoardModel.totalScore.toString().padLeft(6, '0')}',
        Vector2(26, 4),
        6,
        false,
        Colors.white,
        0,
        false);
    gameRef.cam.viewport.add(blinkTextComponentScore);
    blinkTextComponentScore.toggleBlinking();
    textComponentTime = ColorStatusTextComponent(
        'TIME : ${gBoardModel.levelPlayTime.toString().padLeft(3, '0')}',
        Vector2(180, 4),
        fontSize: 10,
        isBlinking: false,
        tcolor: Colors.white,
        interval: 0.0,
        position: Vector2(180, 4));
    /*textComponentTime = await TextUtils.addTextToview(
        gameRef,
        'TIME : ${gBoardModel.levelPlayTime.toString().padLeft(3, '0')}',
        Vector2(180, 4),
        6,
        true,
        Colors.white,
        0,
        false);*/
    gameRef.cam.viewport.add(textComponentTime);

    Vector2 horizontalArrowButtonSize = Vector2(28, 14);
    Vector2 verticalArrowButtonSize = Vector2(14, 28);

    wallkButton = GenericButton(
        position:
            Vector2(gameRef.camDimension.x / 2, gameRef.camDimension.y - 16),
        buttonIconPath: Assets.resources.images.arrowsCam2.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.down),
        buttonSize: horizontalArrowButtonSize,
        isTiled: true);
    //gameRef.cam.viewport.add(downftArrowButtons);

    lookButton = GenericButton(
        position: Vector2(gameRef.camDimension.x / 2, 16),
        buttonIconPath: Assets.resources.images.arrowsCam1.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.up),
        buttonSize: horizontalArrowButtonSize,
        isTiled: true);
    //gameRef.cam.viewport.add(upArrowButtons);

    touchButton = GenericButton(
        position: Vector2(16, gameRef.camDimension.y / 2),
        buttonIconPath: Assets.resources.images.arrowsCam4.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.left),
        buttonSize: verticalArrowButtonSize,
        isTiled: true);
    //gameRef.cam.viewport.add(leftArrowButtons);

    talkButton = GenericButton(
        position:
            Vector2(gameRef.camDimension.x - 16, gameRef.camDimension.y / 2),
        buttonIconPath: Assets.resources.images.arrowsCam3.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.right),
        buttonSize: verticalArrowButtonSize,
        isTiled: true);
    //gameRef.cam.viewport.add(rightArrowButtons);
    //=====================================
    /*flameIcon = GenericButton(
        position: Vector2(248, 8),
        buttonIconPath: Assets.resources.images.potionSheet.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.right),
        buttonSize: Vector2(14, 14));
    gameRef.cam.viewport.add(flameIcon);*/
    energyBar = EnergyBar(
        position: Vector2(248, 2),
        currentEnergy: gBoardModel.energyCount.toDouble(),
        energyBarSize: Vector2(14, 14),
        maxEnergy: 50,
        size: Vector2(50, 14));
    gameRef.cam.viewport.add(energyBar);
    timeIcon = GenericButton(
        position: Vector2(205, 8),
        buttonIconPath: Assets.resources.images.timeicon1.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.right),
        buttonSize: Vector2(14, 14));
    //gameRef.cam.viewport.add(timeIcon);

    bombIcon = GenericButton(
        position: Vector2(290, 8),
        buttonIconPath: Assets.resources.images.bombIcon1.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.right),
        buttonSize: Vector2(14, 14));
    //gameRef.cam.viewport.add(bombIcon);
    /*scoreIcon = GenericButton(
        position: Vector2(52, 8),
        buttonIconPath: Assets.resources.images.scoreicon1.path,
        behavior: ArrowButtonTapHandler(arrowDirection: ArrowDirection.right),
        buttonSize: Vector2(14, 14));*/

    scoreIcon = GenericSpriteAnimation(
        spriteAnimation: gameRef.cardCacheService.scoreIcon,
        animationSize: Vector2(32, 32),
        position: Vector2(18, 8),
        behaviors: []);
    gameRef.cam.viewport.add(scoreIcon);

    buttonSndFXVolume = GameButton(
        position: Vector2(20, 175),
        imagePath: Assets.resources.images.soundfxVolume.path,
        behavior: SoundButtonTapHandler(),
        imgSize: Vector2((34) / 2, (34) / 2),
        isSimpleSpriteSheet: true,
        columns: 4,
        rows: 1);
    //Volume for sound fx
    //buttonSndFXVolume.currentFrameIndex = gameRef.ap.volumeLevels.indexOf(GameAudioPlayer.soundfxVolume);
    gameRef.cam.viewport.add(buttonSndFXVolume);
    buttonMscFXVolume = GameButton(
        position: Vector2(40, 175),
        imagePath: Assets.resources.images.musicfxVolume.path,
        behavior: MusicButtonTapHandler(),
        imgSize: Vector2((34) / 2, (34) / 2),
        isSimpleSpriteSheet: true,
        columns: 4,
        rows: 1);
    //Volume for sound Music
    //buttonMscFXVolume.currentFrameIndex = gameRef.ap.volumeLevels.indexOf(GameAudioPlayer.musicfxVolume);
    gameRef.cam.viewport.add(buttonMscFXVolume);
  }
}
