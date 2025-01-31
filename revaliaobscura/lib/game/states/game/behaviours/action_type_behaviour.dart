import 'package:coolorburn/game/states/game/view/entity_ui_manager.dart';
import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/actionable_entitty_component.dart';
import 'package:coolorburn/utils/ui/game_generic_button.dart';
import 'package:coolorburn/utils/ui/generic_button_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class EntityActionTapHandler extends Behavior<GenericButton>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  ActionableType actionType;
  GenericButtonManager buttonManager;

  EntityActionTapHandler(
      {required this.actionType, required this.buttonManager})
      : super();
  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Example: Scale the button as an animation effect
    gameRef.gboard.actionType = actionType;
    print("GLobal actionType  set to $actionType");
    //EntityUIManager.blinkEntity(parent);
    buttonManager.onButtonTapped(parent);
    super.onTapDown(event);
  }
}
