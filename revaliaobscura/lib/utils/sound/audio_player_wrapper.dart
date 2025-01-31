import 'package:coolorburn/gen/assets.gen.dart';

abstract class AudioPlayerWrapper {
  static final  List<String> hitHurtSounds = [
  Assets.resources.audio.hitHurt1,
  Assets.resources.audio.hitHurt2,
  Assets.resources.audio.hitHurt3,
  Assets.resources.audio.hitHurt4,
  Assets.resources.audio.hitHurt6,
  Assets.resources.audio.hitHurt7,
  Assets.resources.audio.hitHurt8,
  Assets.resources.audio.hitHurt9,
  Assets.resources.audio.hitHurt10,
  Assets.resources.audio.hitHurt11,
  Assets.resources.audio.hitHurt12,
 
];

static final  List<String> blipSelectSounds = [
  Assets.resources.audio.blipSelect1,
  Assets.resources.audio.blipSelect2,
  Assets.resources.audio.blipSelect3,
  Assets.resources.audio.blipSelect4,
  Assets.resources.audio.blipSelect5,
  Assets.resources.audio.blipSelect6,
  Assets.resources.audio.blipSelect7,
  Assets.resources.audio.blipSelect8,

];

  Future<void> initSfxPool(List<String> soundPaths);
 

  void playSoundFx(String path);

  Future<void> playMusic(String path, {bool loop = false});
   

  Future<void> stopMusic();

  Future<void> stopSfx();
}