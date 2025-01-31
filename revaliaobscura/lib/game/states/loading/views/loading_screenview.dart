import 'dart:async';

import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gen/assets.gen.dart';
import 'package:coolorburn/utils/ui/text_component.dart';
import 'package:coolorburn/utils/text_utils.dart';
import 'package:flame/components.dart';

class LoadingView extends World
    with HasGameRef<RevaliaObs>
    implements ViewTransitionInterface {
 
  late BlinkingTextComponent textComponentLoading;
  late BlinkingTextComponent textComponentLevel;

  @override
 void  onLoad()  {
    
    init() ;
    super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    print("LoadingView onMount");
    loadLevel();
  }

  @override
  void onRemove() {
    //removeAll([gameBackground,textComponentLoading,textComponentLevel]);
    super.onRemove();
    textComponentLoading.disableBlinking();
    gameRef.removeFromParent();
    textComponentLoading.removeFromParent();
    textComponentLevel.removeFromParent();
    print("LoadingView resources cleaned up");
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

 void loadLevel()  {
    
    gameRef.ap.playMusic(Assets.resources.audio.mfxchoralintro1);
    textComponentLevel.text = "Level ${gameRef.gboard.gBoardModel.currentLevel}";
    Future.delayed(const Duration(milliseconds: 3500), () {
    
      transitionToNextState();
    });
  }

 void init()  {
    textComponentLoading =  TextUtils.addTextToview(
        gameRef,
        "LOADING",
        Vector2(0, 0),
        12,
        true,
        TextUtils.yellowText,
        0.2,
        true);
        textComponentLoading.toggleBlinking();    


     textComponentLevel =  TextUtils.addTextToview(
        gameRef,
        "Level ${gameRef.gboard.gBoardModel.currentLevel}",
        Vector2(0, 75),
        6,
        false,
        TextUtils.coolblueText,
        0.2,
        true);
    
    addAll([gameRef.loadingCacheService.gameBackground, textComponentLoading, textComponentLevel]);
     
  }

  @override
  void transitionToNextState() {
   
    gameRef.gameFsm.gameStart();
  }
}
