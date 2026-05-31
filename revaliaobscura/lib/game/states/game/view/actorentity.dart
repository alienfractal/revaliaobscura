import 'package:revalia/revalia_obs.dart';
import 'package:revalia/game/states/game/model/actor_model.dart';
import 'package:revalia/game/states/game/handlers/actorentity_animation_handler.dart';
import 'package:revalia/game/states/game/services/card_logic_service.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:flame/components.dart';

import 'package:flame_behaviors/flame_behaviors.dart';

enum ActorActionState { idle, talking }

class ActorEntity extends PositionedEntity
    with HasGameRef<RevaliaObs>
    implements ActionableEntityComponent {
  static const double interactionRange = 60;

  //late final SpriteComponent cardSprite;

  late ActorModel actorModel;
  int cardId = 0;
  static int actorCount = 0;
  late ActorAnimationHandler animationHandler;
  late CardLogicService gameCardLogicService;
  late String actorDialogueId = "";
  ActorActionState actionState = ActorActionState.idle;
  double _actionSecondsRemaining = 0;

  ActorEntity(
      {required this.actorModel, required super.position, required super.size})
      : super(anchor: Anchor.center, behaviors: []) {
    // Initialize the card with default behaviors or properties
    // For example, you can add a visual component based on the card type
    // or add specific behaviors like flip, move, etc.
    actorCount++;
    cardId = actorCount;
    animationHandler = ActorAnimationHandler();
    gameCardLogicService = CardLogicService();
    if (actorModel.status == ActorModel.EMPTY_ENEMY) {
      print("enemy card detected card.position ${position.x} ${position.y}");
    } else if (actorModel.status == ActorModel.RELIC) {
      print("relic card detected card.position ${position.x} ${position.y}");
    }
  }

  @override
  void onLoad() {
    super.onLoad();
    animationHandler.gameRef = gameRef;
    //print('cardModel.x  cardModel.y cardModel.value ${cardModel.x} ${cardModel.y} ${cardModel.value}');
    if (actorModel.status == ActorModel.DIRT) {
      animationHandler.init(
          gameRef.actorCacheService.dirtAnimation, Vector2.all(32), this);
      return;
    } else if (actorModel.status == ActorModel.FLOOR) {
      animationHandler.init(
          gameRef.actorCacheService.walkingArea, Vector2(256, 32), this);
      return;
    } else if (actorModel.status == ActorModel.BACK_ANIM) {
      animationHandler.init(
          gameRef.actorCacheService.gameTownAnimationBackground,
          Vector2(320, 200),
          this);
      return;
    } else if (actorModel.status == ActorModel.OLD_SAILOR) {
      animationHandler.init(
          gameRef.actorCacheService.npcOldSailorIdle, Vector2(50, 85), this);
      return;
    }

    print("cardModel.value ${actorModel.status}");
    animationHandler.init(
        gameRef.actorCacheService.getAnimation(actorModel.status),
        Vector2.all(32),
        this);
  }

  /// Updates the state of the card view.
  @override
  void update(double dt) {
    super.update(dt);
    if (actionState == ActorActionState.talking) {
      _actionSecondsRemaining -= dt;
      if (_actionSecondsRemaining <= 0) {
        actionState = ActorActionState.idle;
        animationHandler.showIdle();
      }
    }

    if (animationHandler.isBombCardDone(this)) {
      animationHandler.init(
          gameRef.actorCacheService.rubbleAnimation, Vector2.all(32), this);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    //print("CardView onRemove");
    animationHandler.cleanUpAnimations();
    removeFromParent();
  }

  @override
  void onLook() {
    gameRef.gboard.callRenderDialogueOnError("player_error_observe");
  }

  @override
  void onMove(Vector2 position) {
    // TODO: implement onMove
  }

  @override
  void onTalk() {
    if (!isPlayerWithinInteractionRange()) {
      gameRef.gboard.callRenderDialogueOnError("player_error_talk");
      return;
    }

    gameRef.gboard.callRenderDialogue(this);
  }

  @override
  void onTouch() {
    gameRef.gboard.callRenderDialogueOnError("player_error_interact");
  }

  void requestTalk({required double durationSeconds}) {
    _actionSecondsRemaining = durationSeconds;
    actionState = ActorActionState.talking;
    animationHandler.showTalk();
  }

  @override
  void onUse() {
    gameRef.gboard.callRenderDialogueOnError("player_error_interact");
  }

  bool isPlayerWithinInteractionRange() {
    return gameRef.gboard.playerEntity.position.distanceTo(position) <=
        interactionRange;
  }

  void performAction(ActionableType actionType) {
    switch (actionType) {
      case ActionableType.look:
        onLook();
        break;
      case ActionableType.touch:
        onTouch();
        break;
      case ActionableType.talk:
        onTalk();
        break;
      case ActionableType.use:
        onUse();
        break;
      case ActionableType.move:
        break;
    }
  }
}
