import 'dart:async';

import 'package:revalia/utils/sound/audio_player_wrapper.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class GameAudioPlayer extends AudioPlayerWrapper {
  static final Map<String, AudioPool> _audioPools = {};
  AudioPlayer? _musicAudioPlayer;
  StreamSubscription? _musicCompletionSubscription;
  int _musicToken = 0;

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
  void playSoundFx(String path) {
    if (_audioPools.containsKey(path)) {
      try {
        _audioPools[path]
            ?.start(volume: soundFxVolume)
            .then((value) => print('Sound Played now plz fuckoff'));
      } catch (e) {
        debugPrint("Error playing sound effect $path: $e");
      }
    } else {
      debugPrint("AudioPool not initialized for $path");
    }
  }

  // Play background music
  @override
  Future<void> playMusic(
    String path, {
    bool loop = false,
    int playCount = 1,
  }) async {
    if (playCount < 1) {
      throw ArgumentError.value(playCount, 'playCount', 'Must be at least 1');
    }
    if (loop && playCount != 1) {
      throw ArgumentError(
        'playCount cannot be combined with loop: true',
      );
    }

    await stopMusic();
    final token = _musicToken;
    try {
      if (loop) {
        _musicAudioPlayer = await FlameAudio.loop(path, volume: musicVolume);
        isMusicPlaying = true;
      } else {
        await _playFiniteMusic(path, playCount, token);
      }
    } catch (e) {
      debugPrint("Error playing music $path: $e");
    }
  }

  Future<void> _playFiniteMusic(
    String path,
    int playsRemaining,
    int token,
  ) async {
    final player = await FlameAudio.play(path, volume: musicVolume);
    if (token != _musicToken) {
      await player.stop();
      return;
    }

    _musicAudioPlayer = player;
    isMusicPlaying = true;
    await _musicCompletionSubscription?.cancel();
    _musicCompletionSubscription = player.onPlayerComplete.listen((_) {
      if (token != _musicToken) {
        return;
      }
      if (playsRemaining > 1) {
        unawaited(_continueFiniteMusic(path, playsRemaining - 1, token));
      } else {
        _musicAudioPlayer = null;
        isMusicPlaying = false;
      }
    });
  }

  Future<void> _continueFiniteMusic(
    String path,
    int playsRemaining,
    int token,
  ) async {
    try {
      await _playFiniteMusic(path, playsRemaining, token);
    } catch (e) {
      if (token == _musicToken) {
        _musicAudioPlayer = null;
        isMusicPlaying = false;
      }
      debugPrint("Error repeating music $path: $e");
    }
  }

  // Stop background music
  @override
  Future<void> stopMusic() async {
    _musicToken++;
    await _musicCompletionSubscription?.cancel();
    _musicCompletionSubscription = null;
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
