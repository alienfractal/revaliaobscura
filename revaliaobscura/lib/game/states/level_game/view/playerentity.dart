import 'dart:math';

import 'package:revalia/game/states/level_game/handlers/playerentity_animation_handler.dart';
import 'package:revalia/game/states/level_game/model/player_model.dart';
import 'package:revalia/game/states/level_game/services/player_logic_service.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum PlayerActionState { idle, walking, talking, dialogueLocked, disabled }

class PlayerPosEntity extends PositionedEntity with HasGameRef<RevaliaObs> {
  late PlayerModel playerModel;
  late PlayerLogicService playerLogicService;
  late PlayerAnimationHandler playerAnimationHandler;
  late Point playerStartPoint;

  double speed = 25.0;
  double timeCounter = 0.0;
  Vector2 originalPosition = Vector2(0, 0);
  Vector2 destination = Vector2(-1, -1);

  PlayerActionState actionState = PlayerActionState.idle;
  double _actionSecondsRemaining = 0;
  LevelEntity? _pendingInteractionTarget;
  ActionableType? _pendingInteractionType;

  PlayerPosEntity(
      {required this.playerModel, required super.position, required super.size})
      : super(anchor: Anchor.bottomCenter) {
    playerLogicService = PlayerLogicService();
    playerAnimationHandler = PlayerAnimationHandler();
  }

  @override
  void onRemove() {
    super.onRemove();
    playerAnimationHandler.cleanUpAnimations();
    removeFromParent();
  }

  @override
  void onLoad() {
    super.onLoad();
    //debugMode = true;
    print("EnemyView onLoad");
    playerAnimationHandler.init(this, gameRef);
    playerStartPoint = position.toPoint();
    print(
        "player entity detected entity.position ${playerStartPoint.x} ${playerStartPoint.y}");
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (actionState) {
      case PlayerActionState.walking:
        _updateWalking(dt);
        break;
      case PlayerActionState.talking:
        _actionSecondsRemaining -= dt;
        if (_actionSecondsRemaining <= 0) {
          _enterIdle();
        }
        break;
      case PlayerActionState.idle:
      case PlayerActionState.dialogueLocked:
      case PlayerActionState.disabled:
        break;
    }
  }

  void makeVisible(bool visible) {}

  void _updateWalking(double dt) {
    // Calculate the direction to the destination
    final direction = (destination - position).normalized();

    // Calculate the distance to move this frame
    final distanceToMove = speed * dt;

    // Calculate the distance remaining to the destination
    final distanceRemaining = position.distanceTo(destination);

    // If we're close enough to the destination, stop moving
    if (distanceRemaining <= distanceToMove) {
      position.setFrom(destination);
      _enterIdle();
      _resolvePendingInteraction();
      return;
    }

    // Move the component
    position += direction * distanceToMove;
  }

  bool requestMove(Vector2 newLocation, {bool keepPendingInteraction = false}) {
    if (actionState == PlayerActionState.disabled ||
        actionState == PlayerActionState.talking ||
        actionState == PlayerActionState.dialogueLocked) {
      return false;
    }
    if (!keepPendingInteraction) {
      _clearPendingInteraction();
    }
    destination = gameRef.gboard.constrainToWalkingArea(newLocation);
    actionState = PlayerActionState.walking;
    playerAnimationHandler.showWalk(destination);
    return true;
  }

  bool requestActorAction({
    required ActionableType actionType,
    required LevelEntity target,
  }) {
    if (actionState == PlayerActionState.disabled ||
        actionState == PlayerActionState.talking ||
        actionState == PlayerActionState.dialogueLocked) {
      return false;
    }

    if (target.shouldApproachFor(actionType) &&
        !target.isPlayerWithinInteractionRange()) {
      _pendingInteractionTarget = target;
      _pendingInteractionType = actionType;
      return requestMove(
        gameRef.gboard.interactionDestinationFor(target),
        keepPendingInteraction: true,
      );
    }

    _clearPendingInteraction();
    playerAnimationHandler.showIdle(target.interactionPoint);
    target.performAction(actionType);
    return true;
  }

  bool requestTalk({required double durationSeconds}) {
    if (actionState == PlayerActionState.disabled) {
      return false;
    }
    _actionSecondsRemaining = durationSeconds;
    actionState = PlayerActionState.talking;
    playerAnimationHandler.showTalk();
    return true;
  }

  void disableActions() {
    actionState = PlayerActionState.disabled;
    playerAnimationHandler.showIdle(position);
  }

  void lockForDialogue() {
    actionState = PlayerActionState.dialogueLocked;
    playerAnimationHandler.showIdle(position);
  }

  void _enterIdle() {
    actionState = PlayerActionState.idle;
    playerAnimationHandler.showIdle(destination);
  }

  void _resolvePendingInteraction() {
    final target = _pendingInteractionTarget;
    final actionType = _pendingInteractionType;
    _clearPendingInteraction();
    if (target == null || actionType == null || !target.isMounted) {
      return;
    }
    playerAnimationHandler.showIdle(target.interactionPoint);
    target.performAction(actionType);
  }

  void _clearPendingInteraction() {
    _pendingInteractionTarget = null;
    _pendingInteractionType = null;
  }
}
