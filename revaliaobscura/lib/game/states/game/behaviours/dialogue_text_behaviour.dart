import 'package:coolorburn/game/states/game/view/dialog_frame_entity.dart';
import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/dialogsystem/dialog_manager.dart';
import 'package:coolorburn/utils/dialogsystem/dialogue.dart';
import 'package:coolorburn/utils/ui/color_status_text_component.dart';
 
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
 

class ColorStatusTextBehaviour extends Behavior<ColorStatusTextComponent>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  int textId =-1 ;

  ColorStatusTextBehaviour({required this.textId}) : super();
  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("ColorStatusTextBehaviour textId ${textId}");
    String nextDialogueEvent = DialogueManager.chooseResponse( textId);
    
    print("ColorStatusTextBehaviour nextDialogueEvent ${nextDialogueEvent}");
    gameRef.gboard.removeDialogFrame();
    gameRef.gboard.callRenderDialogue(nextDialogueEvent);
    
      

  }
}
