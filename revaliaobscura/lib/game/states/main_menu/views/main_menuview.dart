import 'package:revalia/revalia_obs.dart';
import 'package:revalia/game/states/main_menu/behaviours/crt_shader_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/music_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/sound_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/start_button_taphandler.dart';
import 'package:revalia/game/states/main_menu/behaviours/game_background_taphandler.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/ui/game_button.dart';
import 'package:revalia/utils/ui/game_generic_button.dart';
import 'package:revalia/utils/ui/text_component.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/image/image_utils.dart';
import 'package:revalia/utils/text_utils.dart';
import 'package:flame/components.dart';

class MainMenuView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
  late BlinkingTextComponent textComponent;
  late BlinkingTextComponent textComponentGameVersion;
  late GameButton buttonStart;
  late GameButton buttonSndFXVolume;
  late GameButton buttonMscFXVolume;
  late GenericButton buttonCrtShader;

  late String gameVersion = "v.0.0.0";

  double emplasedTime = -1.0;
  int count = 0;

  MainMenuView();

  @override
  void onLoad() {
    // TODO: implement onLoad
    super.onLoad();
    loadlLevel();
    print("MainMenuView: onLoad");
  }

  @override
  void onMount() {
    super.onMount();
    print("MainMenuView: onMount");

    count = 0;
    textComponent.toggleBlinking();
    gameRef.ap.stopMusic();

    gameRef.ap.playMusic(Assets.resources.audio.mfxcitygates, loop: true);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    RevaliaObs.logger.d("Screen resized to: $size");
  }

  void loadlLevel() {
    //String buttonText = gameRef.i18nDelegate.currentLocale.t
    textComponent = BlinkingTextComponent(
        AppTranslations.getTranslation('en', 'menu.push_button'),
        Vector2(0, 75),
        fontSize: 6,
        isBlinking: true,
        tcolor: TextUtils.yellowText,
        interval: 0.4);

    textComponent.position = ComponentUtils.centerComponent(
        gameRef.camDimension, textComponent,
        offsetX: 2, offsetY: 4);

    textComponentGameVersion = BlinkingTextComponent(
        'version: $gameVersion', Vector2(0, 75),
        fontSize: 6,
        isBlinking: false,
        tcolor: TextUtils.yellowText,
        interval: 0.2);

    textComponentGameVersion.position = ComponentUtils.centerComponent(
        gameRef.camDimension, textComponentGameVersion,
        offsetX: 2, offsetY: 5);

    buttonStart = GameButton(
        position: Vector2(50, 74),
        imagePath: Assets.resources.images.buttonstart.path,
        behavior: StartButtonTapHandler(),
        imgSize: Vector2(100, 22));
    buttonStart.position = ComponentUtils.centerComponent(
        gameRef.camDimension, buttonStart,
        offsetX: 2, offsetY: 0);

    buttonSndFXVolume = GameButton(
        position: Vector2(20, 175),
        imagePath: Assets.resources.images.soundfxVolume.path,
        behavior: SoundButtonTapHandler(),
        imgSize: Vector2((34) / 2, (34) / 2),
        isSimpleSpriteSheet: true,
        columns: 4,
        rows: 1);
    //buttonSndFXVolume.currentFrameIndex = gameRef.ap.volumeLevels.indexOf(GameAudioPlayer.soundfxVolume);
    buttonMscFXVolume = GameButton(
        position: Vector2(40, 175),
        imagePath: Assets.resources.images.musicfxVolume.path,
        behavior: MusicButtonTapHandler(),
        imgSize: Vector2((34) / 2, (34) / 2),
        isSimpleSpriteSheet: true,
        columns: 4,
        rows: 1);
    buttonCrtShader = GenericButton(
      position: Vector2(60, 175),
      buttonIconPath: 'resources/images/crton-32x32-8.png',
      behavior: CrtShaderButtonTapHandler(),
      buttonSize: Vector2(17, 17),
      isAnimated: true,
      animationFrames: 8,
      animationStepTime: 0.12,
      animationFrameSize: Vector2(32, 32),
    );
    // buttonMscFXVolume.currentFrameIndex = gameRef.ap.volumeLevels.indexOf(GameAudioPlayer.musicfxVolume);

    // Game Tiele sprite

    final gameTitle = gameRef.menuCacheService.gameTitle.getSpriteComponent();
    final companyTitle =
        gameRef.menuCacheService.companyTitle.getSpriteComponent();
    final gameSubTitle =
        gameRef.menuCacheService.gameSubTitle.getSpriteComponent();
    companyTitle.position = Vector2((gameRef.camDimension.x / 2) - 70, 160);
    gameTitle.position = ComponentUtils.centerComponent(
        gameRef.camDimension, gameTitle,
        offsetX: 2, offsetY: -1);
    gameSubTitle.position = ComponentUtils.centerComponent(
        gameRef.camDimension, gameSubTitle,
        offsetX: 2, offsetY: 2);
    addAll([
      GameBackgroundTapComponent(
          gameRef.menuCacheService.gameBackground.getSpriteComponent()),
      buttonStart,
      textComponent,
      gameTitle,
      companyTitle,
      textComponentGameVersion,
      gameSubTitle,
      buttonSndFXVolume,
      buttonMscFXVolume,
      buttonCrtShader,
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void transitionToNextState() {
    // print("transitionToNextState");
    gameRef.gameFsm.gameLoading();
  }

  @override
  void onRemove() {
    super.onRemove();
  }
}
