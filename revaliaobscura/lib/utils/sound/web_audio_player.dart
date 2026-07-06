import 'dart:async';

import 'package:revalia/utils/sound/audio_player_wrapper.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart' as log;

class WebAudioPlayer extends AudioPlayerWrapper {
  late FlutterSoundPlayer _musicPlayer;
  final List<FlutterSoundPlayer?> _sfxPlayers = [];
  final int maxSfxPlayers = 6; // Number of SFX players in the pool
  int _musicToken = 0;
  bool _loopMusic = false;

  WebAudioPlayer();

  @override
  Future<void> initSfxPool(List<String> soundPaths) async {
    _musicPlayer = FlutterSoundPlayer();
    _musicPlayer.setLogLevel(log.Level.info);
    await _musicPlayer.openPlayer();

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
    _musicToken++;
    final token = _musicToken;
    _loopMusic = loop;
    await _stopMusicPlayer();
    await _startMusic(path, token: token);
  }

  Future<void> _startMusic(String path, {required int token}) async {
    await _musicPlayer.startPlayer(
      fromURI: "assets/$path",
      codec: Codec.mp3,
      whenFinished: () {
        if (_loopMusic && token == _musicToken) {
          unawaited(_restartLoop(path, token));
        }
      },
    );
  }

  Future<void> _restartLoop(String path, int token) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_loopMusic || token != _musicToken) {
      return;
    }

    try {
      await _stopMusicPlayer();
      if (!_loopMusic || token != _musicToken) {
        return;
      }
      await _startMusic(path, token: token);
    } catch (e, stackTrace) {
      print('Error looping music $path: $e');
      print('StackTrace: ${stackTrace.toString()}');
    }
  }

  @override
  void playSoundFx(String path) async {
    try {
      for (var player in _sfxPlayers) {
        if (player != null && player.isStopped) {
          await player.startPlayer(
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
    _musicToken++;
    _loopMusic = false;
    await _stopMusicPlayer();
  }

  Future<void> _stopMusicPlayer() async {
    try {
      await _musicPlayer.stopPlayer();
    } catch (_) {
      // FlutterSound can throw when asked to stop an already-stopped player.
    }
  }

  @override
  Future<void> stopSfx() async {
    for (var player in _sfxPlayers) {
      await player?.stopPlayer();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.closePlayer();
    for (var player in _sfxPlayers) {
      await player?.closePlayer();
    }
  }
}
