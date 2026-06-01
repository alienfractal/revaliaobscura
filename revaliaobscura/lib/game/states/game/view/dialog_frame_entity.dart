import 'dart:async';
import 'dart:ui';

import 'package:revalia/game/states/game/behaviours/dialogue_text_behaviour.dart';
import 'package:revalia/dialoguefsm/dialogue.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/dialogsystem/dialog_event_manager.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/ui/dialogue_text_component%20.dart';
import 'package:revalia/utils/ui/game_text_component.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum DialoguePhase {
  inactive,
  playerInquiry,
  npcResponse,
  replyOptions,
  screenMessage
}

class DialogFrameEntity extends PositionedEntity with HasGameRef<RevaliaObs> {
  List<GameTextComponent> textLinesList = [];
  bool isDialogActive = false;
  DialoguePhase _phase = DialoguePhase.inactive;
  Dialogue? _currentDialogue;
  double _phaseSecondsRemaining = 0;
  DialogFrameEntity({required super.position, required super.size})
      : super(anchor: Anchor.center, behaviors: []);

  @override
  void update(double dt) {
    super.update(dt);
    if (_phase == DialoguePhase.inactive ||
        _phase == DialoguePhase.replyOptions) {
      return;
    }
    _phaseSecondsRemaining -= dt;
    if (_phaseSecondsRemaining <= 0) {
      _advancePhase();
    }
  }

  @override
  void onMount() {
    // TODO: implement onMount
    super.onMount();
    print("DialogFrameEntity  onMount");
    isDialogActive = true;
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
    final paint = Paint()
      ..color = Color.from(
          alpha: 1.0,
          red: 25.0 / 255.0,
          green: 25.0 / 255.0,
          blue: 25.0 / 255.0);
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onRemove() {
    super.onRemove();
    isDialogActive = false;
    _phase = DialoguePhase.inactive;
  }

  void initDialog(String dialogueActorId) {
    print("talk?");
    print(" initDialog dialogueActorId $dialogueActorId");
    DialogueManager.setTranslations(
        AppTranslations.translationsFor(gameRef.currentLocale));

    final current = DialogueManager.startConversation(dialogueActorId);
    _showDialogue(current);
  }

  void loadDialogueTextToFrame(String dialogueId) {
    print("loadDialogueTextToFrame dialogueId $dialogueId");

    if (dialogueId == "end") {
      DialogueManager.endDialogue();
      clearDialogText();
      removeFromParent();
      isDialogActive = false;
      _phase = DialoguePhase.inactive;
      gameRef.gboard.playerEntity.requestTalk(durationSeconds: 1.5);

      return;
    }
    clearDialogText();

    final current = DialogueManager.startDialogue(dialogueId);
    _showDialogue(current);
  }

  void _showDialogue(Dialogue current) {
    print("current.text ${current.text}");
    print("current.playerText ${current.playerText}");
    if (current.id == "error") {
      DialogEventManager.notifycation(event: current.text);
      return;
    }

    setPlayerInquiry(current);
    DialogEventManager.notifycation(event: current.text);
    _currentDialogue = current;
    _phase = DialoguePhase.playerInquiry;
    _phaseSecondsRemaining = 3.5;
    gameRef.gboard.playerEntity.requestTalk(durationSeconds: 3.5);
    DialogEventManager.notifycation(event: current.text);
  }

  void _advancePhase() {
    if (_phase == DialoguePhase.screenMessage) {
      clearDialogText();
      isDialogActive = false;
      _phase = DialoguePhase.inactive;
      removeFromParent();
      return;
    }

    final current = _currentDialogue;
    if (current == null) {
      _phase = DialoguePhase.inactive;
      return;
    }
    clearDialogText();
    switch (_phase) {
      case DialoguePhase.playerInquiry:
        setNpcResponse(current);
        gameRef.gboard.playerEntity.lockForDialogue();
        gameRef.gboard.activeActor.requestTalk(durationSeconds: 3.5);
        _phase = DialoguePhase.npcResponse;
        _phaseSecondsRemaining = 3.5;
        break;
      case DialoguePhase.npcResponse:
        setReplyOptions(current);
        _phase = DialoguePhase.replyOptions;
        break;
      case DialoguePhase.screenMessage:
        break;
      case DialoguePhase.inactive:
      case DialoguePhase.replyOptions:
        break;
    }
  }

  void setReplyOptions(Dialogue current) {
    for (int i = 0; i < current.responses.length; i++) {
      DialogueResponse response = current.responses[i];
      GameTextComponent txtResponse = GameTextComponent(response.text,
          fontSize: 8,
          isBlinking: false,
          interval: 0,
          tcolor: Color.fromARGB(255, 0, 195, 255),
          position: Vector2(16, ((i * 16) + 8).toDouble()));
      //txtResponse.updateUI(ColorStatusTextComponent.HIGHLIGHT);
      txtResponse.add(DialogueReplyTextBehaviour(textId: i, dialogue: current));
      textLinesList.add(txtResponse);
    }
    addAll(textLinesList);
  }

  void setNpcResponse(Dialogue current) {
    DialogueTextComponent textGreet = DialogueTextComponent(
        text: current.text,
        position: Vector2(16, 0),
        textColor: Color.fromARGB(255, 255, 145, 0));

    add(textGreet);

    addAll(textLinesList);
  }

  void setPlayerInquiry(Dialogue current) {
    DialogueTextComponent textGreet = DialogueTextComponent(
        text: current.playerText,
        position: Vector2(16, 0),
        textColor: Color.fromARGB(255, 72, 145, 0));
    add(textGreet);
  }

  void setScreenMessage(String message) {
    DialogueTextComponent textGreet = DialogueTextComponent(
        text: message,
        position: Vector2(16, 0),
        textColor: Color.fromARGB(255, 72, 145, 0),
        fontName: "press2p",
        fontSize: 6);
    add(textGreet);
  }

  void showScreenMessage(String message, {double durationSeconds = 2}) {
    clearDialogText();
    setScreenMessage(message);
    isDialogActive = true;
    _currentDialogue = null;
    _phase = DialoguePhase.screenMessage;
    _phaseSecondsRemaining = durationSeconds;
  }

  void clearDialogText() {
    textLinesList.clear();
    removeAll(children);
  }
}
