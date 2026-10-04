import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/ui/game_text_component.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class DialogueResponseTapBehaviour extends Behavior<GameTextComponent>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  final int responseIndex;
  final Dialogue dialogue;

  DialogueResponseTapBehaviour({
    required this.responseIndex,
    required this.dialogue,
  }) : super();

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("Clicked on response index :  $responseIndex");
    final nextDialogueEvent =
        DialogueManager.chooseResponse(dialogue, responseIndex);

    print("loadDialogueTextToFrame nextDialogueEvent $nextDialogueEvent");
    gameRef.gboard.df?.clearDialogText();
    gameRef.gboard.df?.loadDialogueTextToFrame(nextDialogueEvent);
  }
}
