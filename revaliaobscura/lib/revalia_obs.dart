import 'dart:async';
import 'dart:ui' as ui;

import 'package:revalia/game/states/game/services/actor_cache_service.dart';
import 'package:revalia/game/states/game/services/player_cache_service.dart';
import 'package:revalia/game/states/game/view/gameboard_view.dart';
import 'package:revalia/game/states/end/views/end_screenview.dart';
import 'package:revalia/game/states/loading/services/loading_cache_service.dart';
import 'package:revalia/game/states/loading/views/loading_screenview.dart';
import 'package:revalia/game/states/main_menu/services/menu_cache_serivce.dart';
import 'package:revalia/game/states/main_menu/views/main_menuview.dart';
import 'package:revalia/game/states/score/view/score_screenview.dart';
import 'package:revalia/gamefsm/fsm.dart';
import 'package:revalia/gamefsm/game_fsm.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/translation/app_translations.dart';
import 'package:revalia/utils/sound/web_audio_player.dart';

import 'package:flame/camera.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class ViewTransitionInterface {
  void transitionToNextState();
}

class RevaliaObs extends FlameGame {
  ui.FragmentShader? shader;
  ui.Image? texture;
  late final CameraComponent cam;
  late WebAudioPlayer ap;
  late GameFsm gameFsm;
  final GameboardView gboard = GameboardView();
  final MainMenuView menuView = MainMenuView();
  final LoadingView loadingView = LoadingView();
  final GameEndView endView = GameEndView();
  final GameScoreView scoreView = GameScoreView();
  static final Logger logger = Logger();
  Vector2 camDimension = Vector2(320, 200);
  late FixedResolutionViewport viewport;
  late bool isCrtShaderActive;
  late ui.FragmentProgram uiProgram;

  late ActorCacheService actorCacheService;
  late MenuCacheSerivce menuCacheService;
  late LoadingCacheService loadingCacheService;
  late PlayerCacheService enemyCacheService;
  late GameWidget gameWidget;
  AppTranslations appTranslations = AppTranslations();

  String currentLocale = 'en';

  RevaliaObs() {
    ap = WebAudioPlayer();
    isCrtShaderActive = false;
    debugMode = true;

    actorCacheService = ActorCacheService();
    menuCacheService = MenuCacheSerivce();
    loadingCacheService = LoadingCacheService();
    enemyCacheService = PlayerCacheService();
  }

  @override
  void onAttach() {
    // TODO: implement onAttach
    super.onAttach();
  }

  @override
  void onDispose() {
    RevaliaObs.logger.d("CoolOrBurn: onDispose");
    texture?.dispose();
    texture = null;
    super.onDispose();
  }

  @override
  void onMount() {
    super.onMount();
    RevaliaObs.logger.d("CoolOrBurn: onMount");
    print(" Translate : ${AppTranslations.getTranslation('en', 'game.title')}");
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    RevaliaObs.logger.d("Screen resized to: $size");
  }

  @override
  void render(Canvas canvas) {
    if (!isCrtShaderActive) {
      super.render(canvas);
      return;
    }

    texture?.dispose();
    texture = captureGameTexture();

    if (shader != null && texture != null) {
      final shaderPainter = ShaderPainter(shader: shader, texture: texture);
      shaderPainter.paint(canvas, size.toSize());
      return;
    }

    super.render(canvas);
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    RevaliaObs.logger.d("CoolOrBurn: onLoad");
    // Load the shader
    uiProgram =
        await ui.FragmentProgram.fromAsset('resources/shaders/test.frag');
    await actorCacheService.preloadAnimations(this);
    await actorCacheService.preloadSprites(this);
    await menuCacheService.preloadSprites(this);
    await loadingCacheService.preloadSprites(this);
    await ap.initSfxPool(Assets.resources.audio.values);
    await enemyCacheService.preloadAnimations(this);
    await appTranslations.loadTranslations();
    await DialogueManager.loadDialogueGraph(
      assetPath: 'resources/dialogues/revalia_dialogues.json',
      translations: AppTranslations.translationsFor(currentLocale),
    );

    if (isCrtShaderActive) {
      shader = uiProgram.fragmentShader();
      texture = captureGameTexture();
    }

    PackageInfo.fromPlatform().then((packageInfo) async {
      RevaliaObs.logger.d(packageInfo.toString());
      menuView.gameVersion = packageInfo.version;
      gameFsm = GameFsm(currentState: Fsm.gmenu, mainGame: this);

      viewport = FixedResolutionViewport(resolution: camDimension);
      cam = CameraComponent.withFixedResolution(
          world: menuView, width: camDimension.x, height: camDimension.y);

      cam.viewport = viewport;
      cam.viewfinder.anchor = Anchor.topLeft;
      // cam.viewfinder.position = size / 4;
      cam.viewfinder.zoom = 1.0;

      addAll([cam, menuView]);
    });
  }

  ui.Image captureGameTexture() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    super.render(canvas);
    final picture = recorder.endRecording();
    return picture.toImageSync(size.x.toInt(), size.y.toInt());
  }

  void toggleCrtShader() {
    setCrtShaderActive(!isCrtShaderActive);
  }

  void setCrtShaderActive(bool active) {
    isCrtShaderActive = active;
    if (isCrtShaderActive) {
      shader = uiProgram.fragmentShader();
      texture = captureGameTexture();
      RevaliaObs.logger.d("RevaliaObs: CRT Shader is active");
    } else {
      shader = null;
      texture?.dispose();
      texture = null;
      RevaliaObs.logger.d("RevaliaObs: CRT Shader is inactive");
    }
  }

  // Method to switch worlds
  void switchToWorld(World newWorld) {
    /*cam.world = gboard; // Switch the camera to focus on the new world
    cam.viewfinder.anchor = Anchor.topLeft;
    add(gboard);*/
    if (newWorld.runtimeType == GameboardView) {
      cam.world = gboard;
    } else if (newWorld.runtimeType == MainMenuView) {
      cam.world = menuView;
    } else if (newWorld.runtimeType == LoadingView) {
      cam.world = loadingView;
    } else if (newWorld.runtimeType == GameEndView) {
      cam.world = endView;
    } else if (newWorld.runtimeType == GameScoreView) {
      cam.world = scoreView;
    }

    cam.viewfinder.anchor = Anchor.topLeft;
    add(newWorld);
  }

  void clearWorld(StateType nextStateType) {
    //print(gameFsm.currentState.toString());
    RevaliaObs.logger.d(gameFsm.currentState.toString());
    switch (nextStateType) {
      case StateType.GameMenu:
        remove(menuView);
        break;
      case StateType.GameLoading:
        remove(loadingView);
        break;
      case StateType.GameStart:
        remove(gboard);
        break;
      case StateType.GameEnd:
        remove(endView);
        break;
      case StateType.GameScore:
        remove(scoreView);
        break;
      default:
        break;
    }
  }
}

class TransEntry<T> {
  final T value;

  TransEntry(this.value);

  // Helper method to retrieve a string
  String? asString() {
    if (value is String) {
      return value as String;
    }
    return null;
  }

  // Helper method to retrieve a map
  Map<String, String>? asMap() {
    if (value is Map<String, String>) {
      return value as Map<String, String>;
    }
    return null;
  }

  // Helper method to retrieve a list
  List<String>? asList() {
    if (value is List<String>) {
      return value as List<String>;
    }
    return null;
  }

  @override
  String toString() {
    return value.toString();
  }
}

//Shader call
class ShaderPainter extends CustomPainter {
  final ui.FragmentShader? shader;
  final ui.Image? texture;

  ShaderPainter({this.shader, this.texture});

  @override
  void paint(Canvas canvas, Size size) {
    if (shader != null && texture != null) {
      shader!.setFloat(0, texture!.width.toDouble()); // uResolution.x
      shader!.setFloat(1, texture!.height.toDouble()); // uResolution.y
      shader!.setImageSampler(0, texture!); // uTexture

      final paint = Paint()..shader = shader;

      // Apply shader effect to entire canvas
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint every frame, since texture and shader may change
  }
}
