import 'dart:async';

import 'package:revalia/utils/sound/audio_player_wrapper.dart';
import 'package:audioplayers/audioplayers.dart';

class WebAudioPlayer extends AudioPlayerWrapper {
  late AudioPlayer _musicPlayer;
  final List<AudioPlayer> _sfxPlayers = [];
  final Set<AudioPlayer> _busySfxPlayers = {};
  final int maxSfxPlayers = 6; // Number of SFX players in the pool
  int _musicToken = 0;
  bool _loopMusic = false;
  String? _currentMusicPath;
  bool _currentMusicLoop = false;
  int _currentMusicPlayCount = 1;
  int _musicPlaysRemaining = 0;

  WebAudioPlayer();

  @override
  Future<void> initSfxPool(List<String> soundPaths) async {
    _musicPlayer = AudioPlayer(playerId: 'music');
    await _musicPlayer.setReleaseMode(ReleaseMode.stop);
    _musicPlayer.onPlayerComplete.listen((_) {
      unawaited(_handleMusicComplete());
    });

    // Initialize the pool of SFX players
    for (int i = 0; i < maxSfxPlayers; i++) {
      final player = AudioPlayer(playerId: 'sfx_$i');
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      player.onPlayerComplete.listen((_) {
        _busySfxPlayers.remove(player);
      });
      _sfxPlayers.add(player);
    }
  }

  @override
  Future<void> playMusic(
    String path, {
    bool loop = false,
    int playCount = 1,
  }) async {
    _validatePlaybackOptions(loop: loop, playCount: playCount);

    if (_currentMusicPath == path &&
        _currentMusicLoop == loop &&
        _currentMusicPlayCount == playCount) {
      return;
    }

    _musicToken++;
    final token = _musicToken;
    _loopMusic = loop;
    _musicPlaysRemaining = playCount;
    try {
      if (token != _musicToken) {
        return;
      }
      await _stopMusicPlayer();
      if (token != _musicToken) {
        return;
      }
      await _startMusic(path);
      _currentMusicPath = path;
      _currentMusicLoop = loop;
      _currentMusicPlayCount = playCount;
    } catch (e, stackTrace) {
      if (token == _musicToken) {
        _currentMusicPath = null;
        _currentMusicLoop = false;
        _currentMusicPlayCount = 1;
        _musicPlaysRemaining = 0;
      }
      print('Error playing music "$path": $e');
      print('StackTrace: ${stackTrace.toString()}');
    }
  }

  Future<void> _startMusic(String path) async {
    await _musicPlayer.setReleaseMode(
      _loopMusic ? ReleaseMode.loop : ReleaseMode.stop,
    );
    await _musicPlayer.play(UrlSource('assets/$path'));
  }

  Future<void> _handleMusicComplete() async {
    if (_loopMusic || _currentMusicPath == null) {
      return;
    }

    _musicPlaysRemaining--;
    if (_musicPlaysRemaining <= 0) {
      _currentMusicPath = null;
      _currentMusicLoop = false;
      _currentMusicPlayCount = 1;
      return;
    }

    final token = _musicToken;
    final path = _currentMusicPath!;
    try {
      await _musicPlayer.play(UrlSource('assets/$path'));
      if (token != _musicToken) {
        await _stopMusicPlayer();
      }
    } catch (e, stackTrace) {
      if (token == _musicToken) {
        _currentMusicPath = null;
        _currentMusicLoop = false;
        _currentMusicPlayCount = 1;
        _musicPlaysRemaining = 0;
      }
      print('Error repeating music "$path": $e');
      print('StackTrace: ${stackTrace.toString()}');
    }
  }

  void _validatePlaybackOptions({
    required bool loop,
    required int playCount,
  }) {
    if (playCount < 1) {
      throw ArgumentError.value(playCount, 'playCount', 'Must be at least 1');
    }
    if (loop && playCount != 1) {
      throw ArgumentError(
        'playCount cannot be combined with loop: true',
      );
    }
  }

  @override
  void playSoundFx(String path) async {
    AudioPlayer? selectedPlayer;
    try {
      for (final player in _sfxPlayers) {
        if (!_busySfxPlayers.contains(player)) {
          selectedPlayer = player;
          _busySfxPlayers.add(player);
          await player.stop();
          await player.play(UrlSource('assets/$path'));
          return;
        }
      }
    } catch (e, stackTrace) {
      if (selectedPlayer != null) {
        _busySfxPlayers.remove(selectedPlayer);
      }
      print('Error: $e');
      print('StackTrace: ${stackTrace.toString()}');
    }
  }

  @override
  Future<void> stopMusic() async {
    _musicToken++;
    _loopMusic = false;
    _currentMusicPath = null;
    _currentMusicLoop = false;
    _currentMusicPlayCount = 1;
    _musicPlaysRemaining = 0;
    await _stopMusicPlayer();
  }

  Future<void> _stopMusicPlayer() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {
      // Web audio backends can throw when asked to stop an already-stopped player.
    }
  }

  @override
  Future<void> stopSfx() async {
    _busySfxPlayers.clear();
    for (final player in _sfxPlayers) {
      await player.stop();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    for (final player in _sfxPlayers) {
      await player.dispose();
    }
  }
}
