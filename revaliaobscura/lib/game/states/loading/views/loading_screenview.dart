import 'package:revalia/game/states/level_game/view/dialog_frame_entity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/ui/text_component.dart';
import 'package:revalia/utils/text_utils.dart';
import 'package:flame/components.dart';

class LoadingView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late BlinkingTextComponent textComponentLoading;
  late BlinkingTextComponent textComponentLevel;
  DialogFrameEntity? _introFrame;
  int _loadToken = 0;

  @override
  void onLoad() {
    init();
    super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    print("LoadingView onMount");
    textComponentLoading.enableBlinking();
    loadLevel(++_loadToken);
  }

  @override
  void onRemove() {
    //removeAll([gameBackground,textComponentLoading,textComponentLevel]);
    super.onRemove();
    _loadToken++;
    textComponentLoading.disableBlinking();
    //removeAll(children);
    print("LoadingView resources cleaned up");
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void loadLevel(int token) {
    gameRef.ap.playMusic(Assets.resources.audio.mfxchoralintro1, loop: true);
    // textComponentLevel.text = "Level ${gameRef.gboard.gBoardModel.currentLevel}";
    String text = "";
    for (int i = 0; i < 5; i++) {
      text += AppTranslations.getTranslation(
          gameRef.currentLocale, 'loading.context_intro[$i]');
      text += " ";
      text += "\n";
    }
    // textComponentLevel.text =text;
    _introFrame?.removeFromParent();
    final df = DialogFrameEntity(
        position: Vector2(160, 120), size: Vector2(256 + 16, 80));
    _introFrame = df;

    add(df);
    df.showScreenMessage(text, durationSeconds: 9.5, onDismissed: () {
      if (!isMounted || token != _loadToken) {
        return;
      }
      transitionToNextState();
    });
  }

  void init() {
    textComponentLoading = TextUtils.addTextToview(gameRef, "LOADING",
        Vector2(0, 0), 12, true, TextUtils.yellowText, 0.2, true);
    textComponentLoading.toggleBlinking();

    textComponentLevel = TextUtils.addTextToview(
        gameRef,
        "Level ${gameRef.gboard.gBoardModel.currentLevel}",
        Vector2(16, 75),
        6,
        false,
        TextUtils.coolblueText,
        0.2,
        false);

    addAll([
      gameRef.loadingCacheService.gameBackground.getSpriteComponent(),
      textComponentLoading
    ]);
  }

  @override
  void transitionToNextState() {
    gameRef.gameFsm.gameStart();
  }
}
