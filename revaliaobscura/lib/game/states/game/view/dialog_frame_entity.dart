 

import 'dart:async';
import 'dart:ui';

import 'package:coolorburn/game/states/game/behaviours/dialogue_text_behaviour.dart';
import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/dialogsystem/dialog_manager.dart';
import 'package:coolorburn/utils/dialogsystem/dialogue.dart';
import 'package:coolorburn/utils/translation/app_translations.dart';
import 'package:coolorburn/utils/ui/color_status_text_component.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class DialogFrameEntity extends PositionedEntity with HasGameRef<RevaliaObs> {
 String? dialogueId; 
 List<ColorStatusTextComponent> textLinesList = []; 
 DialogFrameEntity( { required super.position,required super.size})
      : super(anchor: Anchor.center,  behaviors: [
         
        ]){   }
@override
  void onMount() {
    // TODO: implement onMount
    super.onMount();
    print("DialogFrameEntity  onMount");
  
  
  }

        @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    print("DialogFrameEntity  onLoad");


  }

   @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw the background color
    final paint = Paint()..color = Color.from(alpha: 0.15, red: 41.0/255.0, green: 41.0/255.0, blue: 103.0/255.0);
    canvas.drawRect(size.toRect(), paint);
   
}

  @override
  void onRemove() {
    // TODO: implement onRemove
    super.onRemove();
 
  }

 

   

  void initDialog(String actorDialogueId){

    print("talk?");
    print("actorDialogueId ${actorDialogueId}");
    DialogueManager.loadDialogues(AppTranslations.allTranslations[gameRef.currentLocale]!);
    DialogueManager.startDialogue(actorDialogueId);
    Dialogue? current = DialogueManager.activeDialogue;
 

    if(current == null){return;}
  
    print(current.text);

    setTittleResponse(current);

    for (int i =0; i < current.responses.length;  i++ ) {
    DialogueResponse response = current.responses[i];  
    ColorStatusTextComponent txtResponse = ColorStatusTextComponent(response.text, fontSize: 8, isBlinking: false, interval: 0, tcolor:Color(0xFFFF9000), position: Vector2(16,(16+size.y/3)+(i*16).toDouble()));
    txtResponse.updateUI(ColorStatusTextComponent.HIGHLIGHT);
    txtResponse.add(ColorStatusTextBehaviour(textId: i));
    textLinesList.add(txtResponse);
    
      
      
    }

    addAll(textLinesList); 

  }

  void setTittleResponse(Dialogue current) {
    List<String> texts = current.text.split('.');

    for (int i =0; i < texts.length;  i++ ) {
        ColorStatusTextComponent textGreet = ColorStatusTextComponent(texts[i],  fontSize: 8, isBlinking: false, interval: 0, tcolor:Color(0xFFFF9000), position: Vector2(16,12*i+(size.y/3)-16));
    
    textGreet.updateUI(ColorStatusTextComponent.CRITICAL);
    textGreet.add(ColorStatusTextBehaviour(textId:0));
    textLinesList.add(textGreet);
    add(textGreet);
      
    }
  
  }

  void clearDialog() {
    removeAll(children);
  
  }
}