import 'package:coolorburn/utils/sound/audio_player_wrapper.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class GameAudioPlayer  extends AudioPlayerWrapper{
  static final Map<String, AudioPool> _audioPools = {};
  AudioPlayer? _musicAudioPlayer;

  static bool isMusicPlaying = false;
  static double soundFxVolume = 1.0;
  static double musicVolume = 1.0;

  // Initialize an AudioPool for a given sound
  @override
  Future<void> initSfxPool(List<String> soundPaths) async {
    for (var path in soundPaths) {
      if (!_audioPools.containsKey(path)) {
        try {
          _audioPools[path] =
              await FlameAudio.createPool(path, minPlayers: 1, maxPlayers: 2);
        } catch (e) {
          debugPrint("Error initializing AudioPool for $path: $e");
        }
      }
    }
  }

  // Play a sound effect
    @override
 void playSoundFx(String path)  {
    if (_audioPools.containsKey(path)) {
      try {
         _audioPools[path]?.start(volume: soundFxVolume).then((value) => print('Sound Played now plz fuckoff'));
      } catch (e) {
        debugPrint("Error playing sound effect $path: $e");
      }
    } else {
      debugPrint("AudioPool not initialized for $path");
    }
  }

  // Play background music
    @override
  Future<void> playMusic(String path, {bool loop = false}) async {
    if (isMusicPlaying) {
      await stopMusic();
    }
    try {
      _musicAudioPlayer = await FlameAudio.play(
        path,
        volume: musicVolume,
       
      );
      isMusicPlaying = true;
    } catch (e) {
      debugPrint("Error playing music $path: $e");
    }
  }

  // Stop background music
    @override
  Future<void> stopMusic() async {
    if (_musicAudioPlayer != null) {
      await _musicAudioPlayer?.stop();
      _musicAudioPlayer = null;
      isMusicPlaying = false;
    }
  }

  // Dispose of all audio pools

  void dispose() {
    for (var pool in _audioPools.values) {
      pool.dispose();
    }
    _audioPools.clear();
    stopMusic();
  }

  // Set sound effect volume
  void setSoundFxVolume(double volume) {
    soundFxVolume = volume.clamp(0.0, 1.0);
  }

  // Set music volume
  void setMusicVolume(double volume) {
    musicVolume = volume.clamp(0.0, 1.0);
    if (_musicAudioPlayer != null) {
      _musicAudioPlayer?.setVolume(musicVolume);
    }
  }
  
  @override
  Future<void> stopSfx() {
    // TODO: implement stopSfxMusic
    throw UnimplementedError();
  }
}
