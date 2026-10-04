import 'package:revalia/revalia_obs.dart';
import 'package:revalia/utils/ui/game_button.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class MusicButtonTapHandler extends Behavior<GameButton>
    with TapCallbacks, HasGameRef<RevaliaObs> {
  @override
  void onTapDown(TapDownEvent event) {
    Future.delayed(const Duration(milliseconds: 100), () {
      parent.advanceFrame();

      //gameRef.ap.updateMusicVolume(frameIndex);
    });

    super.onTapDown(event);
  }
}
