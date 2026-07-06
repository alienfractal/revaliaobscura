import 'package:revalia/revalia_obs.dart';
import 'package:revalia/game/states/level_game/model/gameboardmodel.dart';
import 'package:revalia/game/states/level_game/view/market_background_entity.dart';
import 'package:revalia/game/states/level_game/view/gameboard_view.dart';
import 'package:revalia/game/states/main_menu/behaviours/crt_shader_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/music_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/sound_button_taphandler.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/ui/entity_action_tap_handler.dart';

import 'package:revalia/utils/ui/game_button.dart';
import 'package:revalia/utils/ui/game_energy_bar.dart';
import 'package:revalia/utils/ui/game_generic_button.dart';
import 'package:revalia/utils/ui/game_generic_sprite.dart';

import 'package:revalia/utils/ui/game_text_component.dart';
import 'package:revalia/utils/ui/generic_button_manager.dart';
import 'package:revalia/utils/ui/text_component.dart';
import 'package:revalia/utils/text_utils.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class UIGameBoardComponents {
  late RevaliaObs gameRef;
  late GameBoardModel gBoardModel;

  late GameboardView gameboardView;

  late BlinkingTextComponent blinkTextComponentScore;
  late GameTextComponent textComponentTime;
  late BlinkingTextComponent blinkTextComponentEnergy;

  late GenericButton touchButton;
  late GenericButton talkButton;
  late GenericButton lookButton;
  late GenericButton wallkButton;
  late GenericButtonManager gameActionGroup = GenericButtonManager();
  late GenericButton flameIcon;
  late GenericButton timeIcon;
  late GenericButton bombIcon;
  late GenericSpriteAnimation scoreIcon;
  late EnergyBar energyBar;

  late GameButton buttonSndFXVolume;

  late GameButton buttonMscFXVolume;
  late GenericButton buttonCrtShader;

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
    buttonCrtShader.removeFromParent();
  }

  void loadUIComponents(RevaliaObs gameRef) {
    addAnimatedBackground();

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
    textComponentTime = GameTextComponent(
        'TIME : ${gBoardModel.levelPlayTime.toString().padLeft(3, '0')}',
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

    Vector2 horizontalArrowButtonSize = Vector2(24, 24);
    //Vector2 verticalArrowButtonSize = Vector2(14, 28);

    int actoionBarXposition = horizontalArrowButtonSize.x.toInt() + 2;
    int gapx = 32;
    double gapy = 12;
    wallkButton = GenericButton(
        position: Vector2(
            gapx + gameRef.camDimension.x / 2 - actoionBarXposition, gapy),
        spriteComponent:
            gameRef.entitySpriteCache.walkButtonSprite.getSpriteComponent(),
        behavior: EntityActionTapHandler(
            actionType: ActionableType.move, buttonManager: gameActionGroup),
        buttonSize: horizontalArrowButtonSize,
        isTiled: false);
    gameRef.cam.viewport.add(wallkButton);
    gameActionGroup.buttons.add(wallkButton);

    lookButton = GenericButton(
        position: Vector2(
            gapx + gameRef.camDimension.x / 2 - actoionBarXposition * 2, gapy),
        spriteComponent:
            gameRef.entitySpriteCache.lookAtButtonSprite.getSpriteComponent(),
        behavior: EntityActionTapHandler(
            actionType: ActionableType.look, buttonManager: gameActionGroup),
        buttonSize: horizontalArrowButtonSize,
        isTiled: false);
    gameRef.cam.viewport.add(lookButton);
    gameActionGroup.buttons.add(lookButton);
    touchButton = GenericButton(
        position: Vector2(
            gapx + gameRef.camDimension.x / 2 - actoionBarXposition * 3, gapy),
        spriteComponent:
            gameRef.entitySpriteCache.touchButtonSprite.getSpriteComponent(),
        behavior: EntityActionTapHandler(
            actionType: ActionableType.touch, buttonManager: gameActionGroup),
        buttonSize: horizontalArrowButtonSize,
        isTiled: false);
    gameRef.cam.viewport.add(touchButton);
    gameActionGroup.buttons.add(touchButton);

    talkButton = GenericButton(
        position: Vector2(
            gapx + gameRef.camDimension.x / 2 - actoionBarXposition * 4, gapy),
        spriteComponent:
            gameRef.entitySpriteCache.talkToButtonSprite.getSpriteComponent(),
        behavior: EntityActionTapHandler(
            actionType: ActionableType.talk, buttonManager: gameActionGroup),
        buttonSize: horizontalArrowButtonSize,
        isTiled: false);
    gameRef.cam.viewport.add(talkButton);
    gameActionGroup.buttons.add(talkButton);

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

    scoreIcon = GenericSpriteAnimation(
        spriteAnimation: gameRef.entitySpriteCache.scoreIcon,
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
    buttonCrtShader = GenericButton(
      position: Vector2(60, 175),
      buttonIconPath: 'resources/images/crton-32x32-8.png',
      behavior: CrtShaderButtonTapHandler(),
      buttonSize: Vector2(17, 17),
      isAnimated: true,
      animationFrames: 8,
      animationStepTime: 0.12,
      animationFrameSize: Vector2(32, 32),
    );
    gameRef.cam.viewport.add(buttonCrtShader);
  }

  void addAnimatedBackground() {
    gameboardView.add(
      MarketBackgroundEntity(
        position: Vector2(160, 100),
        size: Vector2(320, 200),
      ),
    );
  }
}
