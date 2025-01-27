import 'dart:async';
import 'dart:math';

import 'package:coolorburn/game/states/game/handlers/playerentity_animation_handler.dart';
import 'package:coolorburn/game/states/game/model/player_model.dart';
import 'package:coolorburn/game/states/game/services/player_logic_service.dart';

import 'package:coolorburn/game/states/game/view/actorentity.dart';
import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/actionable_entitty_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class PlayerPosEntity extends PositionedEntity
    with HasGameRef<RevaliaObs>
    implements ActionableEntityComponent {
  late PlayerModel playerModel;
  late PlayerLogicService playerLogicService;
  late PlayerAnimationHandler playerAnimationHandler;
  late Point playerStartPoint;

  double speed = 25.0;
  double timeCounter = 0.0;
  Vector2 originalPosition = Vector2(0, 0);
  Vector2 destination = Vector2(-1, -1);

  bool isWalking = false;

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
    debugMode = true;
    print("EnemyView onLoad");
    playerAnimationHandler.init(this, gameRef);
    playerStartPoint = position.toPoint();
    print(
        "enemy card detected card.position ${playerStartPoint.x} ${playerStartPoint.y}");
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isWalking) {
      moveComponent(destination, dt);
    }
  }

  void makeVisible(bool visible) {}

  void moveComponent(Vector2 destination, double dt) {
    if (!isWalking) {
      return;
    }

    // Calculate the direction to the destination
    final direction = (destination - position).normalized();

    // Calculate the distance to move this frame
    final distanceToMove = speed * dt;

    // Calculate the distance remaining to the destination
    final distanceRemaining = position.distanceTo(destination);

    // If we're close enough to the destination, stop moving
    if (distanceRemaining <= distanceToMove) {
      print("distanceRemaining <= distanceToMove");
      //position = destination; // Snap to the destination
      isWalking = false;

      playerAnimationHandler.triggerIdle(
          cardPosition: destination, resetAnimation: true);
      return;
    }

    // Move the component
    position += direction * distanceToMove;
  }

  @override
  void onLook() {
    // TODO: implement onLook
  }

  @override
  void onMove(Vector2 position) {
    // TODO: implement onMove
    isWalking = true;
    this.destination = destination;
    playerAnimationHandler.triggerWalk(
        cardPosition: destination, resetAnimation: true);
  }

  @override
  void onTalk() {
    // TODO: implement onTalk
  }

  @override
  void onTouch() {
    // TODO: implement onTouch
  }

  @override
  void onUse() {
    // TODO: implement onUse
  }
}
