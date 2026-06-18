import 'dart:io' show Platform;
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer, AssetSource, ReleaseMode;
import 'package:shared_preferences/shared_preferences.dart';

class HapticManager {
  static final HapticManager _instance = HapticManager._internal();
  static HapticManager get instance => _instance;
  HapticManager._internal();

  bool _hapticsEnabled = true;
  bool _platformSupportsHaptics = true;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    } catch (e) {
      _hapticsEnabled = true;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _platformSupportsHaptics = false;
    }
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', enabled);
  }

  bool get isEnabled => _hapticsEnabled && _platformSupportsHaptics;

  Future<void> lightImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> vibrate() async {
    if (!isEnabled) return;
    await HapticFeedback.vibrate();
  }

  Future<void> successPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await HapticFeedback.lightImpact();
  }

  Future<void> errorPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.vibrate();
  }

  Future<void> correctAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> correctAnswerPatternWithIntensity() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.lightImpact();
  }

  Future<void> wrongAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  Future<void> achievementPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  Future<void> levelUpPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }

  Future<void> streakPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  Future<void> milestonePattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }

  Future<void> buttonPressPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> transitionPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> navigationPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> gameStartPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> timerWarningPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  static SoundManager get instance => _instance;
  SoundManager._internal();

  bool _isMuted = false;
  bool _soundEnabled = true;
  double _volume = 1.0;
  bool _isInitialized = false;
  
  // Use a pool of players to prevent overhead of creating new ones
  final Map<String, AudioPlayer> _playerPool = {};
  
  // Preload common players
  static const List<String> _essentialEffects = [
    'click', 'correct', 'incorrect', 'success', 'level_up', 'button_press'
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadPreferences();
    
    // Warm up essential players
    for (final effect in _essentialEffects) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      _playerPool[effect] = player;
    }
    
    _isInitialized = true;
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('sound_muted') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _volume = prefs.getDouble('sound_volume') ?? 1.0;
    } catch (e) {
      _isMuted = false;
      _soundEnabled = true;
      _volume = 1.0;
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_muted', _isMuted);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setDouble('sound_volume', _volume);
    } catch (e) {
      // Silently fail - use default values
    }
  }

  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    _soundEnabled = !muted;
    await _savePreferences();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _savePreferences();
  }

  Future<void> playEffect(String effect) async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.buttonPressPattern();
      return;
    }
    await _playSound(effect);
  }

  Future<void> playHint() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.lightImpact();
      return;
    }
    await _playSound('hint');
  }

  Future<void> playCorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.successPattern();
      return;
    }
    await _playSound('correct');
    await HapticManager.instance.successPattern();
  }

  Future<void> playIncorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.errorPattern();
      return;
    }
    await _playSound('incorrect');
    await HapticManager.instance.errorPattern();
  }

  Future<void> playSuccess() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.successPattern();
      return;
    }
    await _playSound('success');
  }

  Future<void> playClick() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.selectionClick();
      return;
    }
    await _playSound('click');
  }

  Future<void> playStartupSound() async {
    if (_isMuted || !_soundEnabled) return;
    await _playSound('startup');
  }

  Future<void> playCorrectAnswer() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.correctAnswerPattern();
      return;
    }
    await _playSound('correct_answer');
    await HapticManager.instance.correctAnswerPattern();
  }

  Future<void> playWrongAnswer() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.wrongAnswerPattern();
      return;
    }
    await _playSound('wrong_answer');
    await HapticManager.instance.wrongAnswerPattern();
  }

  Future<void> playComplete() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.successPattern();
      return;
    }
    await _playSound('complete');
    await HapticManager.instance.successPattern();
  }

  Future<void> playLevelUp() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.levelUpPattern();
      return;
    }
    await _playSound('level_up');
    await HapticManager.instance.levelUpPattern();
  }

  Future<void> playAchievement() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.achievementPattern();
      return;
    }
    await _playSound('achievement');
    await HapticManager.instance.achievementPattern();
  }

  Future<void> playButtonPress() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.selectionClick();
      return;
    }
    await _playSound('button_press');
    await HapticManager.instance.selectionClick();
  }

  Future<void> playBackgroundMusic(String trackName) async {
    if (_isMuted || !_soundEnabled) return;
  }

  Future<void> stopBackgroundMusic() async {}

  Future<void> pauseBackgroundMusic() async {}

  Future<void> resumeBackgroundMusic() async {}

  Future<void> setBackgroundMusicVolume(double volume) async {
    setVolume(volume);
  }

  Future<void> playGameStart() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.gameStartPattern();
      return;
    }
    await _playSound('game_start');
  }

  Future<void> playTimerTick() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.timerWarningPattern();
      return;
    }
    await _playSound('timer_warning');
  }

  Future<void> playNavigation() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.navigationPattern();
      return;
    }
    await _playSound('navigation');
    await HapticManager.instance.navigationPattern();
  }

  Future<void> playTransition() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.transitionPattern();
      return;
    }
    await _playSound('transition');
    await HapticManager.instance.transitionPattern();
  }

  Future<void> _playSound(String key) async {
    if (!_isInitialized) return;
    final soundFile = _getSoundFile(key);
    try {
      AudioPlayer? player = _playerPool[key];
      if (player == null) {
        player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        _playerPool[key] = player;
      }
      
      // Stop current playback to allow rapid firing of same sound
      await player.stop();
      await player.setVolume(_volume);
      await player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      log('Sound Manager Error ($key): $e');
      HapticManager.instance.buttonPressPattern();
    }
  }

  Future<void> dispose() async {
    for (final player in _playerPool.values) {
      await player.dispose();
    }
    _playerPool.clear();
  }

  String _getSoundFile(String key) {
    switch (key) {
      case 'click': return 'click.wav';
      case 'correct': return 'completion.wav';
      case 'incorrect': return 'bling.wav';
      case 'success': return 'completion.wav';
      case 'hint': return 'click.wav';
      case 'complete': return 'completion.wav';
      case 'level_up': return 'levelup.wav';
      case 'achievement': return 'bling.wav';
      case 'game_start': return 'click.wav';
      case 'timer_warning': return 'click.wav';
      case 'startup': return 'click.wav';
      case 'button_press': return 'click.wav';
      case 'navigation': return 'click.wav';
      case 'transition': return 'click.wav';
      case 'wrong_answer': return 'bling.wav';
      case 'correct_answer': return 'completion.wav';
      default: return 'click.wav';
    }
  }
}