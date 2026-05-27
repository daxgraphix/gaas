import 'dart:io' show Platform;
import 'package:flutter/services.dart';
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
    
    if (Platform.isWindows) {
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
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  Future<void> errorPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  Future<void> correctAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  Future<void> wrongAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
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

  Future<void> initialize() async {
    await _loadPreferences();
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

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    _soundEnabled = !muted;
    await _savePreferences();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _savePreferences();
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

  Future<void> playEffect(String effect) async {
    if (_isMuted) return;

    switch (effect) {
      case 'hint':
        await playHint();
        break;
      case 'correct':
        await playCorrect();
        break;
      case 'incorrect':
        await playIncorrect();
        break;
      case 'success':
        await playSuccess();
        break;
      case 'click':
        await playClick();
        break;
      case 'complete':
        await playComplete();
        break;
      case 'level_up':
        await playLevelUp();
        break;
      case 'achievement':
        await playAchievement();
        break;
      case 'start':
        await playGameStart();
        break;
      case 'timer':
        await playTimerTick();
        break;
    }
  }

  Future<void> playHint() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.lightImpact();
      return;
    }
    await HapticManager.instance.lightImpact();
  }

  Future<void> playCorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.correctAnswerPattern();
      return;
    }
    await HapticManager.instance.correctAnswerPattern();
  }

  Future<void> playIncorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.wrongAnswerPattern();
      return;
    }
    await HapticManager.instance.wrongAnswerPattern();
  }

  Future<void> playSuccess() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.successPattern();
      return;
    }
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  Future<void> playClick() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.selectionClick();
      return;
    }
    await HapticManager.instance.selectionClick();
  }

  Future<void> playStartupSound() async {
    if (_isMuted || !_soundEnabled) return;
    await HapticManager.instance.selectionClick();
  }

  Future<void> playCorrectAnswer() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.correctAnswerPattern();
      return;
    }
    await HapticManager.instance.correctAnswerPattern();
  }

  Future<void> playWrongAnswer() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.wrongAnswerPattern();
      return;
    }
    await HapticManager.instance.wrongAnswerPattern();
  }

  Future<void> playComplete() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.successPattern();
      return;
    }
    await HapticManager.instance.successPattern();
  }

  Future<void> playLevelUp() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.levelUpPattern();
      return;
    }
    await HapticManager.instance.levelUpPattern();
  }

  Future<void> playAchievement() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.achievementPattern();
      return;
    }
    await HapticManager.instance.achievementPattern();
  }

  Future<void> playButtonPress() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.selectionClick();
      return;
    }
    await HapticManager.instance.selectionClick();
  }

  Future<void> playBackgroundMusic(String trackName) async {
    // Background music disabled for Windows compatibility
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
    await HapticManager.instance.gameStartPattern();
  }

  Future<void> playTimerTick() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.timerWarningPattern();
      return;
    }
    await HapticManager.instance.timerWarningPattern();
  }

  Future<void> dispose() async {}
}