import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticManager {
  static bool _hapticsEnabled = true;

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    } catch (e) {
      _hapticsEnabled = true;
    }
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', enabled);
  }

  static void lightImpact() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact() {
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact() {
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  static void selectionClick() {
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  static void vibrate() {
    if (_hapticsEnabled) {
      HapticFeedback.vibrate();
    }
  }

  static void successPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  static void errorPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  static void correctAnswerPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.selectionClick();
  }

  static void wrongAnswerPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }

  static void achievementPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.lightImpact();
  }

  static void levelUpPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 250));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    await HapticFeedback.mediumImpact();
  }

  static void streakPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  static void milestonePattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 250));
    await HapticFeedback.mediumImpact();
  }

  static void buttonPressPattern() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.selectionClick();
  }

  void playHint() async {
    // No special sound for hints
  }

  static void transitionPattern() {
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }
}

class SoundManager {
  bool _isMuted = false;
  bool _soundEnabled = true;
  double _volume = 1.0;

  SoundManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('sound_muted') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _volume = prefs.getDouble('sound_volume') ?? 1.0;
    } catch (e) {
      // Default values if loading fails
      _isMuted = false;
      _soundEnabled = true;
      _volume = 1.0;
    }
  }

  Future<void> initialize(bool soundEnabled) async {
    _soundEnabled = soundEnabled;
    _isMuted = !soundEnabled;
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
      // Ignore save errors
    }
  }

  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get soundEnabled => _soundEnabled;

  Future<void> playEffect(String effect) async {
    if (_isMuted) return;

    switch (effect) {
      case 'hint':
        // No special sound for hints
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
    }
  }

  Future<void> playCorrect() async {
    if (_isMuted || !_soundEnabled) {
      // Even when sound is disabled, provide haptic feedback
      HapticManager.correctAnswerPattern();
      return;
    }
    // Enhanced sound sequence for correct answer
    await SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 150));
    await SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 100));
    await SystemSound.play(SystemSoundType.click);
    HapticManager.correctAnswerPattern();
  }

  Future<void> playIncorrect() async {
    if (_isMuted || !_soundEnabled) {
      // Even when sound is disabled, provide haptic feedback
      HapticManager.wrongAnswerPattern();
      return;
    }
    await SystemSound.play(SystemSoundType.alert);
    HapticManager.wrongAnswerPattern();
  }

  Future<void> playSuccess() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    HapticManager.successPattern();
  }

  Future<void> playClick() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playStartupSound() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCorrectAnswer() async {
    if (_isMuted || !_soundEnabled) return;
    await playCorrect();
  }

  Future<void> playWrongAnswer() async {
    if (_isMuted || !_soundEnabled) return;
    await playIncorrect();
  }

  Future<void> playComplete() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    HapticManager.successPattern();
  }

  Future<void> playLevelUp() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    HapticManager.levelUpPattern();
  }

  Future<void> playAchievement() async {
    if (_isMuted || !_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    HapticManager.achievementPattern();
  }

  Future<void> playButtonPress() async {
    if (_isMuted || !_soundEnabled) return;
    await playClick();
  }

  Future<void> playBackgroundMusic(String trackName) async {
    // Background music is intentionally disabled on Windows to avoid native
    // audio plugin build failures. Keep the method as a no-op for callers.
  }

  Future<void> stopBackgroundMusic() async {}

  Future<void> pauseBackgroundMusic() async {}

  Future<void> resumeBackgroundMusic() async {}

  Future<void> setBackgroundMusicVolume(double volume) async {
    setVolume(volume);
  }

  Future<void> dispose() async {}
}
