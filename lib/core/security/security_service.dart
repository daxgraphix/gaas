import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance {
    _instance ??= SecurityService._();
    return _instance!;
  }

  SecurityService._();

  static const String _secretKey = 'GAAS_SECURE_KEY_2024';

  String encryptData(String data) {
    final key = _secretKey.codeUnits;
    final dataBytes = utf8.encode(data);
    final encrypted = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ key[i % key.length]);
    }
    
    return base64Encode(encrypted);
  }

  String decryptData(String encryptedData) {
    final key = _secretKey.codeUnits;
    final encrypted = base64Decode(encryptedData);
    final decrypted = <int>[];
    
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ key[i % key.length]);
    }
    
    return utf8.decode(decrypted);
  }

  Future<void> setSecureString(SharedPreferences prefs, String key, String value) async {
    final encryptedValue = encryptData(value);
    await prefs.setString('sec_$_secretKey$key', encryptedValue);
  }

  Future<String?> getSecureString(SharedPreferences prefs, String key) async {
    final encryptedValue = prefs.getString('sec_$_secretKey$key');
    if (encryptedValue == null) return null;
    return decryptData(encryptedValue);
  }

  String sanitizeInput(String input, {int maxLength = 50}) {
    if (input.isEmpty) return '';
    
    String sanitized = input.replaceAll(RegExp('[<>"\']'), '');
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    sanitized = sanitized.trim();
    
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }

  bool isValidName(String name) {
    if (name.isEmpty || name.length > 30) return false;
    if (RegExp(r'^[\w\s]+$').hasMatch(name)) return true;
    return false;
  }

  int validateAndSanitizeScore(int score, int maxValue) {
    if (score < 0) return 0;
    if (score > maxValue) return maxValue;
    return score;
  }

  bool isValidLevel(int level, {int min = 1, int max = 30}) {
    return level >= min && level <= max;
  }

  String generateSecureId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999);
    return base64Encode(utf8.encode('$timestamp$randomPart'));
  }

  bool isPlatformSecure() {
    if (kDebugMode) return false;
    return true;
  }

  Future<Map<String, dynamic>> exportSecureData(SharedPreferences prefs) async {
    final exportData = <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
      'data': <String, dynamic>{},
    };
    
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (!key.startsWith('sec_') && 
          !key.startsWith('level_progress_') && 
          !key.startsWith('statistics_')) {
        continue;
      }
      
      final value = prefs.getString(key);
      if (value != null) {
        if (key == 'user_session') {
          exportData['data']['user_session'] = utf8.decode(base64Decode(value));
        } else {
          exportData['data'][key] = value;
        }
      }
    }
    
    return exportData;
  }
}