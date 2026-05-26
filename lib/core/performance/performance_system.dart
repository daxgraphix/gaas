import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceConfig {
  final bool enableCaching;
  final bool lazyLoadAssets;
  final int maxCacheSize;
  final Duration assetExpiry;
  final bool enablePerfMonitoring;
  final int targetFps;

  const PerformanceConfig({
    this.enableCaching = true,
    this.lazyLoadAssets = true,
    this.maxCacheSize = 50 * 1024 * 1024,
    this.assetExpiry = const Duration(hours: 24),
    this.enablePerfMonitoring = true,
    this.targetFps = 60,
  });

  PerformanceConfig copyWith({
    bool? enableCaching,
    bool? lazyLoadAssets,
    int? maxCacheSize,
    Duration? assetExpiry,
    bool? enablePerfMonitoring,
    int? targetFps,
  }) {
    return PerformanceConfig(
      enableCaching: enableCaching ?? this.enableCaching,
      lazyLoadAssets: lazyLoadAssets ?? this.lazyLoadAssets,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      assetExpiry: assetExpiry ?? this.assetExpiry,
      enablePerfMonitoring: enablePerfMonitoring ?? this.enablePerfMonitoring,
      targetFps: targetFps ?? this.targetFps,
    );
  }
}

class PerformanceMetrics {
  final double averageFps;
  final double frameTimeMs;
  final int memoryUsageMb;
  final int cacheHits;
  final int cacheMisses;
  final Duration loadTime;
  final int renderSkipped;

  const PerformanceMetrics({
    this.averageFps = 60.0,
    this.frameTimeMs = 16.67,
    this.memoryUsageMb = 0,
    this.cacheHits = 0,
    this.cacheMisses = 0,
    this.loadTime = Duration.zero,
    this.renderSkipped = 0,
  });

  double get cacheHitRate =>
      cacheHits + cacheMisses > 0 ? cacheHits / (cacheHits + cacheMisses) : 0.0;
}

final performanceConfigProvider =
    StateNotifierProvider<PerformanceConfigNotifier, PerformanceConfig>(
      (ref) => PerformanceConfigNotifier(),
    );

class PerformanceConfigNotifier extends StateNotifier<PerformanceConfig> {
  PerformanceConfigNotifier() : super(const PerformanceConfig());

  void enableCaching(bool enabled) {
    state = state.copyWith(enableCaching: enabled);
  }

  void setMaxCacheSize(int size) {
    state = state.copyWith(maxCacheSize: size);
  }

  void setTargetFps(int fps) {
    state = state.copyWith(targetFps: fps.clamp(30, 120));
  }

  void reset() {
    state = const PerformanceConfig();
  }
}

final performanceMetricsProvider =
    StateNotifierProvider<PerformanceMetricsNotifier, PerformanceMetrics>(
      (ref) => PerformanceMetricsNotifier(),
    );

class PerformanceMetricsNotifier extends StateNotifier<PerformanceMetrics> {
  PerformanceMetricsNotifier() : super(const PerformanceMetrics());

  void recordFrame(double frameTimeMs) {
    final newAverageFps = 1000 / frameTimeMs;
    state = PerformanceMetrics(
      averageFps: (state.averageFps * 0.9 + newAverageFps * 0.1),
      frameTimeMs: frameTimeMs,
      memoryUsageMb: state.memoryUsageMb,
      cacheHits: state.cacheHits,
      cacheMisses: state.cacheMisses,
      loadTime: state.loadTime,
      renderSkipped: state.renderSkipped,
    );
  }

  void recordCacheHit() {
    state = PerformanceMetrics(
      averageFps: state.averageFps,
      frameTimeMs: state.frameTimeMs,
      memoryUsageMb: state.memoryUsageMb,
      cacheHits: state.cacheHits + 1,
      cacheMisses: state.cacheMisses,
      loadTime: state.loadTime,
      renderSkipped: state.renderSkipped,
    );
  }

  void recordCacheMiss() {
    state = PerformanceMetrics(
      averageFps: state.averageFps,
      frameTimeMs: state.frameTimeMs,
      memoryUsageMb: state.memoryUsageMb,
      cacheHits: state.cacheHits,
      cacheMisses: state.cacheMisses + 1,
      loadTime: state.loadTime,
      renderSkipped: state.renderSkipped,
    );
  }

  void recordLoadTime(Duration time) {
    state = PerformanceMetrics(
      averageFps: state.averageFps,
      frameTimeMs: state.frameTimeMs,
      memoryUsageMb: state.memoryUsageMb,
      cacheHits: state.cacheHits,
      cacheMisses: state.cacheMisses,
      loadTime: time,
      renderSkipped: state.renderSkipped,
    );
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final int accessCount;

  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.lastAccessed,
    this.accessCount = 0,
  });

  CacheEntry<T> withAccess() {
    return CacheEntry(
      value: value,
      createdAt: createdAt,
      lastAccessed: DateTime.now(),
      accessCount: accessCount + 1,
    );
  }

  bool isExpired(Duration maxAge) {
    return DateTime.now().difference(createdAt) > maxAge;
  }
}

class GameCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final int maxSize;
  final Duration expiry;
  int _hits = 0;
  int _misses = 0;

  GameCache({this.maxSize = 100, this.expiry = const Duration(hours: 1)});

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.isExpired(expiry)) {
      _cache.remove(key);
      _misses++;
      return null;
    }

    _cache[key] = entry.withAccess();
    _hits++;
    return entry.value;
  }

  void set(String key, T value) {
    if (_cache.length >= maxSize) {
      _evictOldest();
    }
    _cache[key] = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
  }

  void _evictOldest() {
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  int get size => _cache.length;
  double get hitRate => _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0;
}

final questionCacheProvider = Provider<GameCache<dynamic>>((ref) {
  return GameCache<dynamic>(maxSize: 500, expiry: const Duration(hours: 24));
});

class AssetPreloader {
  final GameCache<dynamic> _assetCache = GameCache();
  final List<String> _pendingAssets = [];
  bool _isPreloading = false;

  Future<void> preloadAssets(List<String> assetPaths) async {
    for (final path in assetPaths) {
      if (_assetCache.get(path) == null) {
        _pendingAssets.add(path);
      }
    }

    if (!_isPreloading && _pendingAssets.isNotEmpty) {
      _isPreloading = true;
      await _loadPendingAssets();
      _isPreloading = false;
    }
  }

  Future<void> _loadPendingAssets() async {
    while (_pendingAssets.isNotEmpty) {
      final batch = _pendingAssets.take(5).toList();
      _pendingAssets.removeRange(
        0,
        batch.length.clamp(0, _pendingAssets.length),
      );

      for (final asset in batch) {
        _assetCache.set(asset, true);
      }

      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  bool isLoaded(String path) => _assetCache.get(path) != null;
}

final assetPreloaderProvider = Provider<AssetPreloader>((ref) {
  return AssetPreloader();
});

class FrameRateOptimizer {
  static void optimizeForFrameRate() {
    if (kDebugMode) return;
  }

  final DateTime _lastFrame = DateTime.now();
  int _frameCount = 0;
  double _currentFps = 60.0;

  void tick() {
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFrame).inMilliseconds;

    if (elapsed >= 1000) {
      _currentFps = (_frameCount / elapsed) * 1000;
      _frameCount = 0;
    }
  }

  double get currentFps => _currentFps;
  bool get isSmooth => _currentFps >= 55.0;
  bool get hasJank => _currentFps < 50.0;
}

final frameRateOptimizerProvider = Provider<FrameRateOptimizer>((ref) {
  return FrameRateOptimizer();
});

class BatteryOptimizer {
  static const double normalBatteryThreshold = 0.2;
  static const double lowBatteryThreshold = 0.1;

  bool _isLowPowerMode = false;
  bool _shouldReduceRendering = false;
  bool _shouldReduceAudio = false;
  bool _shouldReduceAnimations = false;

  void updateBatteryLevel(double level) {
    _isLowPowerMode = level < normalBatteryThreshold;
    _shouldReduceRendering = level < lowBatteryThreshold;
    _shouldReduceAudio = level < normalBatteryThreshold;
    _shouldReduceAnimations = _shouldReduceRendering;
  }

  bool get isLowPowerMode => _isLowPowerMode;
  bool get shouldReduceRendering => _shouldReduceRendering;
  bool get shouldReduceAudio => _shouldReduceAudio;
  bool get shouldReduceAnimations => _shouldReduceAnimations;
}

final batteryOptimizerProvider = Provider<BatteryOptimizer>((ref) {
  return BatteryOptimizer();
});

class OfflineManager {
  bool _isOffline = false;
  final Set<String> _offlineCapableRoutes = {};
  final GameCache<dynamic> _offlineData = GameCache();

  void setOfflineCapable(String route, bool capable) {
    if (capable) {
      _offlineCapableRoutes.add(route);
    } else {
      _offlineCapableRoutes.remove(route);
    }
  }

  bool isRouteOfflineCapable(String route) =>
      _offlineCapableRoutes.contains(route);

  Future<void> cacheForOffline(String key, dynamic data) async {
    _offlineData.set(key, data);
    _offlineData.set('${key}_timestamp', DateTime.now().toIso8601String());
  }

  dynamic getOfflineData(String key) => _offlineData.get(key);

  bool get isOffline => _isOffline;
  void setOfflineMode(bool offline) => _isOffline = offline;
}

final offlineManagerProvider = Provider<OfflineManager>((ref) {
  return OfflineManager();
});
