import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedQuestion {
  final String id;
  final String operation;
  final int level;
  final int operand1;
  final int operand2;
  final int correctAnswer;
  final String displayString;
  final String? hint;

  CachedQuestion({
    required this.id,
    required this.operation,
    required this.level,
    required this.operand1,
    required this.operand2,
    required this.correctAnswer,
    required this.displayString,
    this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation,
      'level': level,
      'operand1': operand1,
      'operand2': operand2,
      'correctAnswer': correctAnswer,
      'displayString': displayString,
      'hint': hint,
    };
  }

  factory CachedQuestion.fromMap(Map<String, dynamic> map) {
    return CachedQuestion(
      id: map['id'] as String,
      operation: map['operation'] as String,
      level: map['level'] as int,
      operand1: map['operand1'] as int,
      operand2: map['operand2'] as int,
      correctAnswer: map['correctAnswer'] as int,
      displayString: map['displayString'] as String,
      hint: map['hint'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CachedQuestion.fromJson(String source) {
    return CachedQuestion.fromMap(jsonDecode(source));
  }
}

class OfflineCacheService {
  static const String _cachePrefix = 'cached_question_';
  static const String _metadataKey = 'cache_metadata';

  final SharedPreferences _prefs;

  OfflineCacheService(this._prefs);

  Future<void> cacheQuestions(List<CachedQuestion> questions) async {
    for (final q in questions) {
      await _prefs.setString('$_cachePrefix${q.id}', q.toJson());
    }
    await _updateMetadata(questions.length);
  }

  Future<List<CachedQuestion>> getQuestionsForOperation(String operation, int level, {int limit = 50}) async {
    final allKeys = _prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
    final questions = <CachedQuestion>[];
    
    for (final key in allKeys) {
      final json = _prefs.getString(key);
      if (json != null) {
        final q = CachedQuestion.fromJson(json);
        if (q.operation == operation && q.level == level) {
          questions.add(q);
          if (questions.length >= limit) break;
        }
      }
    }
    return questions;
  }

  Future<List<CachedQuestion>> getAllCachedQuestions() async {
    final allKeys = _prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
    final questions = <CachedQuestion>[];
    
    for (final key in allKeys) {
      final json = _prefs.getString(key);
      if (json != null) {
        questions.add(CachedQuestion.fromJson(json));
      }
    }
    return questions;
  }

  Future<void> clearCache() async {
    final allKeys = _prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
    for (final key in allKeys) {
      await _prefs.remove(key);
    }
    await _updateMetadata(0);
  }

  Future<CacheMetadata> getMetadata() async {
    final metadataJson = _prefs.getString(_metadataKey);
    if (metadataJson != null) {
      return CacheMetadata.fromJson(metadataJson);
    }
    return CacheMetadata(totalQuestions: 0, lastUpdated: DateTime.now());
  }

  Future<void> _updateMetadata(int totalQuestions) async {
    final metadata = CacheMetadata(
      totalQuestions: totalQuestions,
      lastUpdated: DateTime.now(),
    );
    await _prefs.setString(_metadataKey, metadata.toJson());
  }

  Future<bool> hasSufficientQuestions(String operation, int level) async {
    final questions = await getQuestionsForOperation(operation, level);
    return questions.length >= 30;
  }
}

class CacheMetadata {
  final int totalQuestions;
  final DateTime lastUpdated;

  CacheMetadata({required this.totalQuestions, required this.lastUpdated});

  Map<String, dynamic> toMap() => {
        'totalQuestions': totalQuestions,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory CacheMetadata.fromMap(Map<String, dynamic> map) => CacheMetadata(
        totalQuestions: map['totalQuestions'] as int,
        lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      );

  String toJson() => jsonEncode(toMap());

  factory CacheMetadata.fromJson(String source) => CacheMetadata.fromMap(jsonDecode(source));
}

final offlineCacheProvider = Provider<OfflineCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OfflineCacheService(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Use SharedPreferences.getInstance() directly or inject via main.dart');
});