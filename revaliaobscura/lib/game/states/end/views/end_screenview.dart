import 'dart:async';

import 'package:revalia/revalia_obs.dart';
import 'package:revalia/game/states/level_game/model/gameboardmodel.dart';
import 'package:revalia/utils/image/image_utils.dart';
import 'package:revalia/utils/ui/text_component.dart';
import 'package:revalia/utils/text_utils.dart';
import 'package:flame/components.dart';

class GameEndView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late SpriteComponent gameBackground;
  late BlinkingTextComponent textComponentEnd;
  late BlinkingTextComponent textComponentMessage;
  int _endToken = 0;

  @override
  void onRemove() {
    super.onRemove();
    _endToken++;
  }

  @override
  void onLoad() {
    init();
  }

  @override
  void onMount() {
    super.onMount();
    final token = ++_endToken;
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!isMounted || token != _endToken) {
        return;
      }
      transitionToNextState();
    });
  }

  void init() {
    textComponentEnd = BlinkingTextComponent('GAME OVER', Vector2(0, 0),
        fontSize: 25,
        isBlinking: true,
        tcolor: TextUtils.yellowText,
        interval: 0.1);
    textComponentEnd.position = ComponentUtils.centerComponent(
        gameRef.camDimension, textComponentEnd,
        offsetX: 2, offsetY: 2);
    textComponentEnd.toggleBlinking();

    gameBackground =
        gameRef.entitySpriteCache.gameBackground.getSpriteComponent();

    textComponentMessage = TextUtils.addTextToview(
        gameRef,
        endingCondition(gameRef.gboard.gBoardModel.flipResultOutcome),
        Vector2((gameRef.camDimension.x / 2.0), gameRef.camDimension.y / 3.0),
        16,
        true,
        TextUtils.coolblueText,
        1.0,
        false);
    textComponentMessage.position = Vector2(
        (gameRef.camDimension.x / 2.0 - (textComponentMessage.size.x / 2.0)),
        gameRef.camDimension.y / 3.0);

    addAll([gameBackground, textComponentEnd, textComponentMessage]);
  }

  @override
  void transitionToNextState() {
    gameRef.gboard.gBoardModel.currentLevel = 0;
    gameRef.ap.stopMusic();
    gameRef.gameFsm.gameMenu();
  }

  String endingCondition(ActionOutcome lastOutcome) {
    if (lastOutcome == ActionOutcome.timeOver) {
      return "OUT OF TIME";
    } else if (lastOutcome == ActionOutcome.invalidMove) {
      return "OUT OF MANA";
    } else {
      return "OUT OF LUCK";
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isLoaded) {}
  }
}
