import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:revalia/game/states/level_game/handlers/level_entity_animation_handler.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/components/entity_action_behaviour.dart';

enum LevelEntityActionState { idle, talking }

abstract class LevelEntity extends PositionedEntity
    with HasGameReference<RevaliaObs>
    implements ActionTarget {
  static const double interactionRange = 60;

  final String? dialogueActorId;
  final LevelEntityAnimationHandler animationHandler =
      LevelEntityAnimationHandler();
  LevelEntityActionState actionState = LevelEntityActionState.idle;
  double _actionSecondsRemaining = 0;

  LevelEntity({
    required super.position,
    required super.size,
    this.dialogueActorId,
    super.behaviors,
  }) : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (actionState == LevelEntityActionState.talking) {
      _actionSecondsRemaining -= dt;
      if (_actionSecondsRemaining <= 0) {
        actionState = LevelEntityActionState.idle;
        animationHandler.showIdle();
      }
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    animationHandler.cleanUpAnimations();
  }

  void requestTalk({required double durationSeconds}) {
    _actionSecondsRemaining = durationSeconds;
    actionState = LevelEntityActionState.talking;
    animationHandler.showTalk();
  }

  bool isPlayerWithinInteractionRange() {
    return gameRef.gboard.playerEntity.position.distanceTo(interactionPoint) <=
        interactionRange;
  }

  @override
  Vector2 get interactionPoint => Vector2(position.x, position.y + size.y / 2);

  bool get canTalk => dialogueActorId != null;

  @override
  bool shouldApproachFor(ActionableType actionType) {
    return _actionBehaviourFor(actionType)?.requiresInteractionRange ?? false;
  }

  @override
  void performAction(ActionableType actionType) {
    final behaviour = _actionBehaviourFor(actionType);
    if (behaviour != null) {
      behaviour.execute();
      return;
    }

    gameRef.gboard.callRenderDialogueOnError(_fallbackDialogFor(actionType));
  }

  EntityActionBehaviour? _actionBehaviourFor(ActionableType actionType) {
    for (final behaviour in children.whereType<EntityActionBehaviour>()) {
      if (behaviour.actionType == actionType) {
        return behaviour;
      }
    }
    return null;
  }

  String _fallbackDialogFor(ActionableType actionType) {
    return switch (actionType) {
      ActionableType.look => 'player_error_observe',
      ActionableType.talk => 'player_error_talk',
      ActionableType.move => 'player_error_walk',
      ActionableType.touch || ActionableType.use => 'player_error_interact',
    };
  }
}
