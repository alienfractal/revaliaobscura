import 'package:revalia/game/states/game/view/dialog_frame_entity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/dialogsystem/dialogue.dart';
import 'package:revalia/utils/ui/game_text_component.dart';
 
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
 

class DialogueReplyTextBehaviour extends Behavior<GameTextComponent>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  int textId =-1 ;
  Dialogue dialogue;

  DialogueReplyTextBehaviour({required this.textId, required this.dialogue}) : super();
  @override
  void update(double dt) {
    // Logic for the flip behavior
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("Clicked on response index :  ${textId}");
    String nextDialogueEvent = DialogueManager.chooseResponse(dialogue,textId);
    
    print("loadDialogueTextToFrame nextDialogueEvent ${nextDialogueEvent}");
    //gameRef.gboard.removeDialogFrame();
    //gameRef.gboard.callRenderDialogue(nextDialogueEvent);
     gameRef.gboard.df?.clearDialogText();
    gameRef.gboard.df?.loadDialogueTextToFrame(nextDialogueEvent);
      

  }
}
