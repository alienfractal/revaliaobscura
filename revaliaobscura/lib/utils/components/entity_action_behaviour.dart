import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

abstract class EntityActionBehaviour extends Behavior<LevelEntity>
    with HasGameReference<RevaliaObs> {
  ActionableType get actionType;

  bool get requiresInteractionRange => false;

  void execute();
}
