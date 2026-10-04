import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:revalia/game/states/level_game/handlers/level_entity_animation_handler.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/components/entity_action_behaviour.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/translation/app_translations.dart';

enum LevelEntityActionState { idle, talking, attacking }

abstract class LevelEntity extends PositionedEntity
    with HasGameReference<RevaliaObs>
    implements ActionTarget {
  static const double interactionRange = 60;

  final String interactionId;
  final String? dialogueActorId;
  final bool isWalkable;
  final LevelEntityAnimationHandler animationHandler =
      LevelEntityAnimationHandler();
  LevelEntityActionState actionState = LevelEntityActionState.idle;
  double _actionSecondsRemaining = 0;

  LevelEntity({
    required super.position,
    required super.size,
    required this.interactionId,
    this.dialogueActorId,
    this.isWalkable = false,
    super.behaviors,
  }) : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (usesPerspectiveScaling) {
      animationHandler.updatePerspectiveScale(interactionPoint.y);
    }
    if (usesDepthSorting) {
      priority = PerspectiveConfig.depthPriorityForFeetY(depthSortY);
    }
    if (actionState == LevelEntityActionState.talking) {
      _actionSecondsRemaining -= dt;
      if (_actionSecondsRemaining <= 0) {
        actionState = LevelEntityActionState.idle;
        animationHandler.showIdle();
      }
    }
  }

  bool get usesPerspectiveScaling => false;
  bool get usesDepthSorting => false;
  double get depthSortY => interactionPoint.y;

  @override
  void onRemove() {
    super.onRemove();
  }

  void requestTalk({required double durationSeconds}) {
    _actionSecondsRemaining = durationSeconds;
    actionState = LevelEntityActionState.talking;
    animationHandler.showTalk();
  }

  void requestAttack({void Function()? onComplete}) {
    actionState = LevelEntityActionState.attacking;
    animationHandler.showAttack(onComplete: () {
      actionState = LevelEntityActionState.idle;
      onComplete?.call();
    });
  }

  bool isPlayerWithinInteractionRange() {
    return game.gboard.playerEntity.position.distanceTo(interactionPoint) <=
        currentInteractionRange;
  }

  double get currentInteractionRange => usesPerspectiveScaling
      ? interactionRange *
          PerspectiveConfig.characterScaleForFeetY(interactionPoint.y)
      : interactionRange;

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

    showInteractionReaction(actionType);
  }

  EntityActionBehaviour? _actionBehaviourFor(ActionableType actionType) {
    for (final behaviour in children.whereType<EntityActionBehaviour>()) {
      if (behaviour.actionType == actionType) {
        return behaviour;
      }
    }
    return null;
  }

  void showInteractionReaction(ActionableType actionType) {
    DialogueManager.setTranslations(
      AppTranslations.translationsFor(game.currentLocale),
    );
    final message = DialogueManager.interactionMessage(
      interactionId,
      actionType == ActionableType.move ? 'walk' : actionType.name,
    );
    game.gboard.showScreenMessage(message);
  }
}
