
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/sound/audio_player_wrapper.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart' as log;




class WebAudioPlayer extends AudioPlayerWrapper {
  late FlutterSoundPlayer? _musicPlayer;
  final List<FlutterSoundPlayer?> _sfxPlayers = [];
  final int maxSfxPlayers = 6; // Number of SFX players in the pool


  WebAudioPlayer();

  @override
  Future<void> initSfxPool(List<String> soundPaths) async {
    // Initialize the music player
 
    _musicPlayer = FlutterSoundPlayer();
    _musicPlayer?.setLogLevel(log.Level.info);
    await _musicPlayer?.openPlayer();

    // Initialize the pool of SFX players
    for (int i = 0; i < maxSfxPlayers; i++) {
      FlutterSoundPlayer? player = FlutterSoundPlayer();
      player.setLogLevel(log.Level.info);
      player = await player.openPlayer();
      _sfxPlayers.add(player);
    }
  }

  @override
  Future<void> playMusic(String path, {bool loop = false}) async {
    await _musicPlayer?.startPlayer(
      fromURI: "assets/$path",
      codec: Codec.mp3,
      whenFinished: () {
        print("Music playback finished.");
      },
    );
  }

  @override
  void playSoundFx(String path) async {

     try {

    for (var player in _sfxPlayers) {
      

      
       if(player!= null && player.isStopped){
        await  player.startPlayer(
        fromURI: "assets/$path",
        codec: Codec.mp3,
        whenFinished: () {
           print("Sound effect finished playing.");
        },
      );
      return;

       }
      }

      } catch (e, stackTrace) {
    print('Error: $e');
    print('StackTrace: ${stackTrace.toString()}');
    
    }
  }


 

  @override
  Future<void> stopMusic() async {
    await _musicPlayer?.stopPlayer();
  }

  @override
  Future<void> stopSfx() async {
    for (var player in _sfxPlayers) {
      await player?.stopPlayer();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer?.closePlayer();
    for (var player in _sfxPlayers) {
      await player?.closePlayer();
    }
  }
}
